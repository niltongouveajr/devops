#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_SCRIPT_LOG_FILE="/srv/config/logs/${HOSTNAME}_gitlab_block_users.log"

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
echo "--------------------"
echo " Gitlab Block Users "
echo "--------------------"
echo ""

echo -n > ${GITLAB_SCRIPT_LOG_FILE}

GITLAB_USER_PAGES=`curl --silent --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users | grep "^X-Total-Pages" | sed 's/[^0-9]*//g'`

COUNTER=1

while [ $COUNTER -le ${GITLAB_USER_PAGES} ];do
  for i in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users?page=${COUNTER}&active=true" | python -m json.tool | grep username | awk -F "\"" '{print $4}' | grep -v root | grep -v ghost | grep -v jenkins | egrep -x '\w{1,7}'` ; do
    LDAP_QUERY=`ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=$i" | grep ^sAMAccountName | awk -F " " '{print $2}'`
    if [ -z "${LDAP_QUERY}" ]; then
      GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=$i | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
      GITLAB_SERVICE_USER=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users?username=$i" | python -m json.tool | grep \"name\" | grep "service user"`
      if [ -z "${GITLAB_SERVICE_USER}" ]; then
        echo "Blocking user: $i (${GITLAB_USER_ID})"
        echo "Blocking user: $i (${GITLAB_USER_ID})" >> "${GITLAB_SCRIPT_LOG_FILE}"
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST ${GITLAB_API_URL}/users/${GITLAB_USER_ID}/block >/dev/null
      else
        echo "Keeping service user: $i (${GITLAB_USER_ID})"
        echo "Keeping service user: $i (${GITLAB_USER_ID})" >> "${GITLAB_SCRIPT_LOG_FILE}"
      fi
    fi
  done
  (( COUNTER++ ))
done

source /srv/config/templates/svn/properties.cfg

MESSAGE=`cat ${GITLAB_SCRIPT_LOG_FILE}`

if [ -z "${MESSAGE}" ]; then
  MESSAGE="No changes"
  exit 0
fi

/srv/config/install/sendemail/sendEmail.pl -f "devops@local" -t $script_emails_devops -u "[DevOps] Gitlab Block Users: $HOSTNAME" -m "$MESSAGE" -s "webmail.local"

echo -e "\nCompleted!\n"
