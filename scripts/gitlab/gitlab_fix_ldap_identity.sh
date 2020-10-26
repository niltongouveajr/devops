#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}//api/v4"
GITLAB_TOKEN="<token>"
GITLAB_USER_LIST="./gitlab_fix_ldap_identity.txt"
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
echo "--------------------------"
echo " Gitlab Fix LDAP Identity "
echo "--------------------------"
echo ""

COUNTER=1

echo "Which users do you want to run for?"
echo ""
echo "1. All Gitlab users"
echo "2. User list (One 'sAMAccountName' per line in '${GITLAB_USER_LIST}' file)"
echo "3. Specific user (e.g: niltongouveajr)"
echo ""
echo -n "Choose an option (1/2/3): "
read OPTION
echo ""

if [[ "${OPTION}" == "1" ]]; then
  while [ "${COUNTER}" -le "${GITLAB_USER_PAGES}" ];do
    for USERNAME in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users?page=${COUNTER}&active=true" | python -m json.tool | grep username | awk -F "\"" '{print $4}' | grep -v root | grep -v ghost | grep -v jenkins | egrep -x '\w{1,7}'` ; do
      GITLAB_USER_ID=$(curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=${USERNAME} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+')
      LDAP_USER_DN=$(ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${USERNAME}" -o ldif-wrap="no" | grep -e ^dn | awk -F ": " '{print $2}' | tr '[:upper:]' '[:lower:]' | sed "s| |%20|g")
      if [ ! -z "${GITLAB_USER_ID}" ] && [ ! -z "${LDAP_USER_DN}" ]; then
        echo "ID: ${GITLAB_USER_ID}"
        echo "Username: ${USERNAME}"
        echo "DN: ${LDAP_USER_DN}"
        #curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/users/${GITLAB_USER_ID}?provider=ldapmain&extern_uid=${LDAP_USER_DN}" | python -m json.tool >/dev/null
        echo "curl --silent --header \"PRIVATE-TOKEN: ${GITLAB_TOKEN}\" -X PUT \"${GITLAB_API_URL}/users/${GITLAB_USER_ID}?provider=ldapmain&extern_uid=${LDAP_USER_DN}\" | python -m json.tool >/dev/null"
        echo ""
      fi
    done
    (( COUNTER++ ))
  done
elif [[ "${OPTION}" == "2" ]]; then
  if [[ -f "${GITLAB_USER_LIST}" ]]; then
    while [ "${COUNTER}" -le "${GITLAB_USER_PAGES}" ];do
      for USERNAME in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/users?page=${COUNTER}&active=true" | python -m json.tool | grep username | awk -F "\"" '{print $4}' | grep -v root | grep -v ghost | grep -v jenkins | egrep -x '\w{1,7}'` ; do
        if [[ ! -z `cat "${GITLAB_USER_LIST}" | grep "${USERNAME}"` ]]; then
          GITLAB_USER_ID=$(curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=${USERNAME} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+')
          LDAP_USER_DN=$(ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${USERNAME}" -o ldif-wrap="no" | grep -e ^dn | awk -F ": " '{print $2}' | tr '[:upper:]' '[:lower:]' | sed "s| |%20|g")
          if [ ! -z "${GITLAB_USER_ID}" ] && [ ! -z "${LDAP_USER_DN}" ]; then
            echo "ID: ${GITLAB_USER_ID}"
            echo "Username: ${USERNAME}"
            echo "DN: ${LDAP_USER_DN}"
            curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/users/${GITLAB_USER_ID}?provider=ldapmain&extern_uid=${LDAP_USER_DN}" | python -m json.tool >/dev/null
            echo ""
          fi
        fi
      done
      (( COUNTER++ ))
    done
  fi
elif [[ "${OPTION}" == "3" ]]; then
  echo -n "Type username: "
  read USERNAME
  echo ""
  GITLAB_USER_ID=$(curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=${USERNAME} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+')
  LDAP_USER_DN=$(ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${USERNAME}" -o ldif-wrap="no" | grep -e ^dn | awk -F ": " '{print $2}' | tr '[:upper:]' '[:lower:]' | sed "s| |%20|g")
  if [ ! -z "${GITLAB_USER_ID}" ] && [ ! -z "${LDAP_USER_DN}" ]; then
    echo "ID: ${GITLAB_USER_ID}"
    echo "Username: ${USERNAME}"
    echo "DN: ${LDAP_USER_DN}"
    curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/users/${GITLAB_USER_ID}?provider=ldapmain&extern_uid=${LDAP_USER_DN}" | python -m json.tool >/dev/null
    echo ""
  else
    echo -e "\n[ Error ] User '${USERNAME}' not found in Gitlab or AD.\n"
    exit 1
  fi
else
  echo -e "\n[ Error ] Invalid option.\n"
  exit 1
fi

echo -e "Completed!\n"
