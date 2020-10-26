#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

REPO_DIR="/srv/gitlab/git-data/repositories"

# Conditions:

if [ ${EUID} -ne 0 ]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [[ ! -d "${REPO_DIR}" ]]; then
  echo -e "\n[ Error ] Repository directory '${REPO_DIR}' not found.\n"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 {customer}/{project}/{repo}\nExample: $0 epson/workforce2/android\n"
  exit 1
fi

# Run

echo ""
echo "------------------"
echo " Gitlab Find Repo "
echo "------------------"
echo ""

find ${REPO_DIR} -name "config" | sort -u | xargs grep "$1" | sed "s|/config.*= | (|g" | sed "s|$|)|g" | awk '{print $2" "$1}' 

echo ""
