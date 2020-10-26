#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <project-id>\n"
  exit 1
fi

# Try access Gitlab via API
TRY_ACCESS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups"`

if [[ ! -z `echo "${TRY_ACCESS}" | grep "401 Unauthorized"` ]]; then
  echo -e "\n[ Error ] Cannot access ${GITLAB_API_URL}. Aborted.\n"
  exit 1
fi

# Run

echo ""
echo "----------------"
echo " Gitlab Project "
echo "----------------"
echo ""

curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/$1" | python -m json.tool
