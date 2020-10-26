#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_REPOS_DIR="/srv/gitlab/git-data/repositories"
GITLAB_REPOS=`find "${GITLAB_REPOS_DIR}" -type d -name "*.git" | grep -v "wiki" | sort -u`

# Run

for GITLAB_REPO in `echo -e "${GITLAB_REPOS}"` ; do
  cd "${GITLAB_REPO}"
  GITLAB_LARGE_FILES=`git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort --numeric-sort --key=2 | cut -c 1-12,41- | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest | grep MiB | tac | head -n 5`
  if [[ ! -z "${GITLAB_LARGE_FILES}" ]]; then
    echo ""
    echo -e "${GITLAB_REPO}"
    git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort --numeric-sort --key=2 | cut -c 1-12,41- | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest | grep MiB | tac | head -n 5
  fi
  cd - >/dev/null
done
