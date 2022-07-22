#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_USER_PAGES=$(curl --silent --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users | grep "^X-Total-Pages" | sed 's/[^0-9]*//g')

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
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
echo "----------------------"
echo " Gitlab Get All Users "
echo "----------------------"
echo ""

COUNTER=1

while [ "${COUNTER}" -le "${GITLAB_USER_PAGES}" ];do
  for USERNAME in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users?page=${COUNTER}&active=true" | python -m json.tool | grep username | awk -F "\"" '{print $4}' | egrep -x '\w{1,7}'` ; do
    GITLAB_USER_ID=$(curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=${USERNAME} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+')
    echo "ID: ${GITLAB_USER_ID}"
    echo "Username: ${USERNAME}"
    echo ""
  done
  (( COUNTER++ ))
done

echo -e "Completed!\n"
