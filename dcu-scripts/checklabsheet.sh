#!/bin/bash

#
# needs to be run on a Unix based system that has bash
# please create a file called 'password.txt' and 'username.txt' and reference them below
#

password=$(< ../password.txt)
user=$(< ../username.txt)
read labsheet

while true; do
  curl -s --head --user "$user:$password" https://ca116.computing.dcu.ie/labsheet-$labsheet.html head -n 1 > "online.txt"
  cat "online.txt" | grep "HTTP"
  sleep 300
done
