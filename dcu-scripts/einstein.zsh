#!/usr/bin/env zsh

# Script to upload a file to Einstein.
#
# Usage:
#
#    $ einstein FILENAME [FILENAMES...]
#
#    ... or ...
#
#    $ zsh einstein FILENAME [FILENAMES...]
#
#    ... or ...
#
#    $ einstein [DIRNAMES...]
#
#    ... or just ...
#
#    $ einstein
#
# You might have to provide your password (but you should only have to do that once).
#
username=hacketj5

#
# Requirements: zsh, curl and sha1sum.
#

# "sha1sum" is apparently known as "shasum" on MacOS.
#
sha1sum="sha1sum"
if ! which $sha1sum
then
   which shasum && sha1sum="shasum"
fi > /dev/null

zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

# ########################################################################
# Arguments.
#
# These are primarily for SB's usage.  They are for installing and testing
# Einstein markers.
#

install_markers=
install_outputs=

while getopts 'ia' opt
do
   case $opt in
      i      ) install_markers="yes" ;;
      a      ) install_outputs="yes" ;;
      \?     ) print "invalid option: -$opt" >&2; exit 1 ;;
   esac
done
shift $((OPTIND-1))

if [[ -n $install_markers ]]
then
   if [[ -f ../Makefile ]] || [[ -f ../makefile ]]
   then
      # Install markers (e.g. with rsync).
      #
      make -C .. install
   else
      print "error: failed to find make file" >&2
      exit 1
   fi
fi

# ########################################################################
# Utilities.

# The output is tweaked somewhat for the case where we're uploading multiple files
# at the same time.
#
reduced_output=''
unless_reduced_output ()
{
   [[ -z $reduced_output ]] && $argv
}

contains ()
{
   local thing=$argv[1]; shift
   [[ ${argv[(ie)$thing]} -le $#argv ]]
}

{
   if [[ -t 1 ]]
   then
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      BLUE='\033[0;34m'
      NC='\033[0m'
   else
      RED=""
      GREEN=""
      BLUE=""
      NC=""
   fi

   coloured ()
   {
      local colour=$argv[1]; shift
      print -- "$colour$argv$NC"
   }
}

http ()
{
   curl --silent --config - $argv <<< "user = $username:$password"
}

# ########################################################################
# Ensure we have a working username and password.
#
# The secret salt here isn't to make the encryption secure; it's rather just to
# reduce the likelihood that somebody stumbles across an unencrytpted password
# in one of the off-site backups.

pw_file=$HOME/.einstein-passwd-v2.txt
secret="Eey6ahchDoho5yu5"

enc=( openssl enc -pbkdf2 -aes256 -base64 -pass pass:$secret -out $pw_file )
dec=( openssl enc -d -pbkdf2 -aes256 -base64 -pass pass:$secret -in $pw_file )

# Deal with legacy versions of openssl.
#
if openssl version | grep -q "OpenSSL 1.0"
then
   enc=( openssl enc -aes256 -base64 -pass pass:$secret -out $pw_file )
   dec=( openssl enc -d -aes256 -base64 -pass pass:$secret -in $pw_file )
fi

{
   # Migration v1 -> v2.
   # Version 1 was using a depricated form of encryption.
   #
   pw_file_v1=$HOME/.einstein-passwd.txt

   if [[ -s $pw_file_v1 ]] && ! [[ -f $pw_file ]]
   then
      if openssl enc -d -aes256 -base64 -pass pass:$secret -in $pw_file_v1 2> /dev/null | $enc
      then
	 chmod 0600 $pw_file
	 rm $pw_file_v1
      fi
   fi

   unset pw_file_v1
}

if [[ -f $pw_file ]] && ! $dec -out /dev/null
then
   rm -v $pw_file
fi

if ! [[ -f $pw_file ]]
then
   print "this-is-not-the-correct-password" | $enc
   chmod 0600 $pw_file
fi

password=$( $dec )

ask_user_for_password ()
{
   print "user:" $(coloured $BLUE $username)
   read -s password"?enter your School of Computing password: "
   print
   print $password | $enc
   chmod 0600 $pw_file
}

while ! http --output /dev/null --write-out "%{http_code}\n" "https://ca000.computing.dcu.ie/einstein/now" | grep -q -w 200
do
   ask_user_for_password
done

# ########################################################################
# Fetch the Einstein task list (and, hence, the module list too).
#
# These are lines of the form:
#
#    75d16fa158ba3c795051fa3b6a4a3a10b580c595 ca114 ca116 ca117
#
# where the hash is the SHA1 hash of the task name, and the rest of the tokens are the modules on which that
# task is available.
#
# For the vast majority of tasks, the task name is unique to the module.
#
# For a number of tasks (e.g. "hello.py"), the same task name is available on several modules.
#

fetch_tasks ()
{
   # This really shouldn't fail but, if it does, then we want to know about it.
   #
   set -e
   print -- $argv
   #
   [[ -f ~/.einstein-tasks.txt.tmp   ]] && chmod u+w ~/.einstein-tasks.txt.tmp
   [[ -f ~/.einstein-tasks.txt       ]] && chmod u+w ~/.einstein-tasks.txt
   [[ -f ~/.einstein-modules.txt.tmp ]] && chmod u+w ~/.einstein-modules.txt.tmp
   [[ -f ~/.einstein-modules.txt     ]] && chmod u+w ~/.einstein-modules.txt
   #
   # If we're running on the Einstein server, then just copy the file.  Otherwise, fetch
   # it over the network.
   #
   if [[ -f "/var/www/termcast/tasks.txt" ]]
   then
      cp "/var/www/termcast/tasks.txt" ~/.einstein-tasks.txt.tmp
   else
      http "https://einstein.computing.dcu.ie/termcast/tasks.txt" > ~/.einstein-tasks.txt.tmp
   fi
   #
   cut -d ' ' -f 2- ~/.einstein-tasks.txt.tmp | tr " " "\n" | sort | uniq > ~/.einstein-modules.txt.tmp
   mv ~/.einstein-modules.txt.tmp ~/.einstein-modules.txt
   mv ~/.einstein-tasks.txt.tmp ~/.einstein-tasks.txt
   set +e
}

if ! [[ -s ~/.einstein-tasks.txt ]]
then
   fetch_tasks "Fetching the Einstein task list..."
fi

last_task_list_update_time=$( zstat +mtime ~/.einstein-tasks.txt )
if (( 60 * 15 < $EPOCHSECONDS - last_task_list_update_time ))
then
   fetch_tasks "Refreshing the Einstein task list (it's more than 15 minutes old)..."
fi

# ########################################################################
# Work out the module at hand (for a particular task file).

# Test whether a string is a known Einstein module name.
#
is_module ()
{
   fgrep -w $argv[1] < ~/.einstein-modules.txt
}

# If the path is something like /home/blott/CA116/week-01/hello.py, then the module is "ca116".
#
get_module_by_path ()
{
   local file=$argv[1]
   local realpath=$file:a

   # Below, "z" means split on IFS/whitespace, "s:/:" means split on directory separators.
   # It would be better to split on "-", "_" and the like too, but I don't know how to do that
   # concisely.
   #
   for component in ${(zs:/:)realpath:h}
   do
      is_module $component:l && return
   done

   false
}

# Like above, but also accept junk like ~/myCA116directory.
#
get_module_by_sloppy_path ()
{
   local mod file=$argv[1]:a:l
   for mod in $( < ~/.einstein-modules.txt )
   do
      if [[ $file == *$mod* ]]
      then
	 print $mod
	 return
      fi
   done
   false
}

# Get a list of modules for which the task has a marker for the upload file name.
# (The intended module can only one of these, because other modules do not have markers!)
#
get_module_by_task ()
{
   local sha1 junk file=$argv[1] task=$file:t
   local -a mods

   print -n $task | $sha1sum | read sha1 junk
   mods=( $( fgrep $sha1 ~/.einstein-tasks.txt ) )

   if [[ $#mods == 0 ]] || [[ $#mods == 1 ]]
   then
      false
   else
      # Shift off the hash (leaving just the modules).
      shift mods
      print -l -- $mods
   fi
}

# This outputs a list of candidate modules for the upload file (and succeeds only if at
# least one module is found).
#
get_modules ()
{
   get_module_by_path $argv || get_module_by_sloppy_path $argv || get_module_by_task $argv
}

# ########################################################################
# Remember a previous module choice.

get_previous_module ()
{
   [[ -s ~/.einstein-previous-module.txt ]] && print -- $( < ~/.einstein-previous-module.txt )
}

remember_previous_module ()
{
   [[ $#argv == 1 ]] && print -- $argv[1] > ~/.einstein-previous-module.txt
}

# ########################################################################
# Handle the actual uploads.

handle_upload ()
{
   local module
   local -a mods selections
   mods=( $( get_modules $argv ) )

   case $#mods in
      0 )
	 print -- "error:" $argv[1]:t "is not a valid task name in any Einstein module" >&2
	 false; return $? ;;

      1 )
	 # There's only one module, so we're done.
	 true ;;

      * )
	 # There is more than one candidate module.  We'll have to ask the user.
	 #
	 # First, ask if they want to re-use a previous choice (if there is one).
	 #
	 if module=$( get_previous_module ) && contains $module $mods
	 then
	    print
	    print "You previously uploaded for module" $( coloured $BLUE $module )"."
	    print "Type 'y' to choose" $( coloured $BLUE $module ) "again (or anything else to pick a different module)."

	    if read -q answer"?? "
	    then
	       mods=( $module )
	       print
	    fi
	 fi
	 #
	 # If there are still multiple choices, then pick from a list.
	 #
	 selections=( $mods )
	 while [[ $#mods != 1 ]]
	 do
	    PS3="Enter one of the number choices above, or the module code... "
	    print -l -- "" "'${BLUE}$argv[1]:t$NC' is a task on the following modules, pick a module...\n"
	    #
	    select module in $selections
	    do
	       if [[ -z $module ]] && [[ -n $REPLY ]] && contains $REPLY $selections
	       then
		  mods=( $REPLY )
	       elif [[ -n $module ]]
	       then
		  mods=( $module )
	       else
		  print
		  print $( coloured $RED "Computer says 'no'; enter either the module code or the corresponding number..." )
	       fi
	       break
	    done
	 done
	 #
	 remember_previous_module $mods[1] ;;
   esac

   module=$mods[1]
   upload_file $module $argv
}

upload_file ()
{
   local module=$argv[1]
   local file=$argv[2]
   local task=$file:t
   local web_page="https://$module.computing.dcu.ie/"

   print "file:" $( coloured $BLUE $( realpath --relative-to=$PWD $file) )
   print "task:" $( coloured $BLUE $module/$task )
   print "web :" $( coloured $BLUE $web_page )
   #
   if [[ $file:a == */markers/* ]]
   then
      # This is an Einstein marker directory.
      #
      reduced_output="yes"
      #
      if [[ -f "$file:a:h/task-description.html" ]]
      then
	 bytes=$( wc -c < "$file:a:h/task-description.html" )
	 sha=$( $sha1sum "$file:a:h/task-description.html" | cut -d ' ' -f 1 )
	 print "note:" $( coloured $BLUE "task-description.html detected" )
	 print "     " $( coloured $BLUE "task-description.html: $bytes byte(s), $sha" )
      else
	 print "note:" $( coloured $BLUE "task-description.html not detected" )
      fi
   fi
   #
   print
   print "Uploading" $( coloured $BLUE $task ) "to Einstein (this may take a few seconds)..."

   mkdir -p ~/.einstein
   http --form "file=@$file" "${web_page}einstein/upload" | tee ~/.einstein/$module-$task.json | format_report $file $module $task
}

format_report ()
{
   local -i passed=0 failed=0 tests=0
   local report module einstein task test_name result

   local call_file=$argv[1]
   local call_module=$argv[2]
   local call_task=$argv[3]

   print
   while read report module einstein task test_name result
   do
      [[ $report == "#test-report" ]] || continue

      tests+=1
      [[ $result == "passed" ]] && print $( coloured $GREEN "*** test $tests: $result" ) && passed+=1
      [[ $result == "failed" ]] && print $( coloured $RED   "*** test $tests: $result" ) && failed+=1
   done

   unless_reduced_output print
   if (( passed < tests ))
   then
      print $( coloured $RED "*** failed: $failed of $tests" )
   fi

   if (( 0 < passed ))
   then
      print $( coloured $GREEN "*** passed: $passed of $tests" )
   fi

   if (( passed == tests ))
   then
      print $( coloured $GREEN "*** overall: correct" )
   else
      print $( coloured $RED "*** overall: incorrect" )
   fi

   unless_reduced_output print
   print $( coloured $BLUE "*** report: https://$call_module.computing.dcu.ie/einstein/report.html" )

   # Use with caution!
   # Only lecturers are ever likely to want to do this.
   #
   # This is used to install the *actual* outputs from the Einstein uploads
   # as the expected outputs for the task.
   #
   if [[ -n $install_outputs ]]
   then
      install_actual_outputs $call_file $call_module $call_task
   fi

   (( passed == tests ))
}

# ########################################################################
# Primarily for SB, to support writing Einstein markers.
#
# Assume that the outputs are correct, and install them in the relevant stdout.txt files.
#
# Here, we embed a CoffeeScript script inside this shell script.
# Yuck!
#
# We do it like this in order to avoid users having to install a second script.
# Also, while it would be possible to parse the JSON with jq, the Javascript
# solution is just cleaner and likely more robust.
#

install_marker_output ()
{
   if ! which coffee > /dev/null
   then
      print
      print "error: installation of actual outputs requires CoffeeScript"
      print
      print "       sudo npm install -g coffee-script"
      print
      print "       (which in turn requires nodejs and npm)"
      exit 1
   fi >&2

   local installation_script=$( mktemp /tmp/install-einstein-marker-output-$USER.XXXXXXXX )
   cat > $installation_script <<EOF
if true  # This gives us more readable indentation, that's all.
   fs = require "fs"

   # The JSON report is on stdin.
   fs.readFile 0, (err, data) ->
      if err
         console.error "error: failed to read JSON #{err}"
         process.exit 1
      else
         for test in JSON.parse(data.toString()).results
            name = test.test
            name = "./" if name == "test0"
            unless 0 <= name.indexOf "/../"
               console.log "    ...installing #{name}stdout.txt"
               fs.writeFile "#{name}stdout.txt", test.stdout, (err) ->
        	  if err
        	     console.error "error: failed to write output #{err}"
        	     process.exit 1
EOF

   coffee $installation_script
   result=$?
   rm $installation_script
   return $result
}

install_actual_outputs ()
{
   local file=$argv[1]
   local module=$argv[2]
   local task=$argv[3]

   local json=$HOME/.einstein/$module-$task.json

   # The JSON is embedded in a rather strange way in the response from the
   # HTTP POST, above.
   #
   # Tidy it up, so that we're left just with the JSON.
   #
   sed -i '/^#test/ d; s/^#json //;' $json
   print -l "" "installing the expected standard output for $task..."

   (
      cd $file:a:h
      install_marker_output < $json
   ) || exit 1
}

# ########################################################################
# Work out the most recently-updated task file in a directory.
#

get_recent_file () {
   local file sha1 junk answer directory=$argv[1]

   for file in $directory/*(.Nom)
   do
      print -n $file:t | $sha1sum | read sha1 junk

      if fgrep -q $sha1 ~/.einstein-tasks.txt
      then
	 {
	    print
	    print "Picking your most recently-edited task file:" $( coloured $BLUE $( realpath --relative-to=$PWD $file ) )
	 } >&2
	 print $file
	 return
      fi
   done

   print $directory
}

# ########################################################################
# Tweak the command-line arguments:
#
#    - empty -> "."
#    - /foobar/hello.py/ -> /foorbar/hello.py/hello.py
#    - /ca116/ -> most recently-edited task file
#    - and expand MVTs
#
# Yikes!
# A recursive shell script!
#
# This will loop for ever if it encounters a malformed MVT task (an MVT task
# which links to itself).

[[ $#argv == 0 ]] && set -- "."

resolve_argument ()
{
   local file=$argv[1]
   local candidate_task_name=$file:a:t

   if [[ -d $file ]] && [[ -f "$file/multi-variant-task.txt" ]]
   then
      file="$file/multi-variant-task.txt"
      reduced_output="yes"

   elif [[ -d $file ]] && [[ -f $file/$candidate_task_name ]]
   then
      file="$file/$candidate_task_name"
      reduced_output="yes"

   elif [[ -d $file ]]
   then
      # Offer the most-recently-updated task file.
      #
      file=$( get_recent_file $file )
   fi

   if [[ -f $file ]] && [[ $file:t == "multi-variant-task.txt" ]]
   then
      variants=( $( < $file ) )
      print "MVT detected; selecting $#variants variant(s):" >&2
      #
      for variant in $variants
      do
	 print "   $file:h/../$variant" >&2
	 resolve_argument "$file:h/../$variant"
      done
   else
      print $file
   fi
}

args=()
for arg in $argv
do
   args+=( $( resolve_argument $arg ) )
done

set -- $args

(( 1 < $#argv )) && reduced_output="yes"
[[ $PWD == */markers/* ]] && reduced_output="yes"

# ########################################################################
# Run all of that...

integer errors=0

for file in $argv
do
   if [[ -f $file ]]
   then
      [[ $#argv == 1 ]] || print -l -- "" "**************************************************************"
      handle_upload $file || errors+=1
   else
      print "error, invalid file: $file" >&2
      errors+=1
   fi
done

(( errors == 0 ))