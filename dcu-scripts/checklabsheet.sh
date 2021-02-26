#!/bin/bash

#
# needs to be run on a Unix based system that has bash
# please create a file called 'password.txt' and 'username.txt' and reference them below
#

password=$(< ../password.txt)
user=$(< ../username.txt)
# read labsheet, lab, week

while true; do
  curl -s --head --user "$user:$password" https://ca117.computing.dcu.ie/html/week02/lab01/01_lab.html head -n 1 > "online.txt"
  cat "online.txt" | grep "HTTP"
  sleep 90
done
