#!/bin/bash

password=$(< ../password.txt)
user=$(< ../username.txt)
read labsheet

while true; do
  curl -s --head --user "$user:$password" https://ca116.computing.dcu.ie/labsheet-$labsheet.html head -n 1 | grep "HTTP" > "online.txt"
  cat "online.txt"
  sleep 300
done
