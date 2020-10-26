#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_API_URL="https://gitlab.local/api/v4"
GITLAB_TOKEN="<token>"

# Run

for i in `ls -1 /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar` ; do
  VNT=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users/$i" | python -m json.tool | grep "username" | awk -F "\"" '{print $4}'`
  echo $i
  echo $VNT
  mv /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.png /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.png.old 2>/dev/null
  wget -q -nv https://devops.local/avatar/$VNT.jpg -O /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.jpg
  ls /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i
  if [ -f "/var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.jpg" ]; then
    convert /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.jpg /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.png
    chown git:git /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/*
  else
    wget -q -nv https://devops.local/avatar/nobody.png -O /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.png
    chown git:git /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/*
  fi
  rm /var/opt/gitlab/gitlab-rails/uploads/system/user/avatar/$i/avatar.jpg
  echo ""
done
