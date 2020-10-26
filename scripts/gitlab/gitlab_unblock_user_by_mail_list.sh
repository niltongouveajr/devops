#!/bin/bash

# Author: Nilton R Gouvea Junior

for i in `cat mails`; do
  if [[ ! -z $i ]]; then 
    gitlab-rails console << EOF
user = User.find_by_email("$i")
user.state = "active"
user.save
exit
EOF
  fi
done
