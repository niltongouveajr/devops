#!/bin/bash
clear

# Author:  Nilton R Gouvea Junior

# Variables

GITLAB_REPOS_DIR="/var/opt/gitlab/git-data/repositories"
GITLAB_REPOS=`find "${GITLAB_REPOS_DIR}" -type d -name "*.git" | grep -v "wiki" | grep -v "deleted" | sort -u`

# Run

for REPO in `echo -e "${GITLAB_REPOS}"` ; do
  cd "${REPO}"
  if [[ `git rev-list HEAD --count` -eq "1" ]]; then
    echo "${REPO}"
  fi
done
