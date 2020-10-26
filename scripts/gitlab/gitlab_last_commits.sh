#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_SCRIPT_DIR="/srv/config/scripts/gitlab"
GITLAB_REPOS_DIR="/var/opt/gitlab/git-data/repositories"
GITLAB_REPOS=`find "${GITLAB_REPOS_DIR}" -maxdepth 3 -type d -name "*.git" | sed "s|/var/opt/gitlab/git-data/repositories/||g" | grep -v "wiki" | grep -v "deleted" | sort` 

# Run

REPO_LIST=$(
for REPO in `echo -e "${GITLAB_REPOS}"` ; do
  cd /var/opt/gitlab/git-data/repositories/${REPO}
  REPO_LOG=`git log --pretty=format:"%ad" --date=short --all --date-order`
  for COMMIT in `echo -e "${REPO_LOG}"` ; do
    echo "${COMMIT} ${REPO}"
  done
  cd - >/dev/null
done
)

#echo -e "Last Update: `date +"%d/%m/%Y - %H:%M:%S"`\n" > ${GITLAB_SCRIPT_DIR}/gitlab_last_commits.log
echo -e "${REPO_LIST}" | sort -n | tac > ${GITLAB_SCRIPT_DIR}/gitlab_last_commits.log
cat ${GITLAB_SCRIPT_DIR}/gitlab_last_commits.log
