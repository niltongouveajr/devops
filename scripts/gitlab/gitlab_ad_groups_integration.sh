#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_AD_GROUPS_FILE="/srv/config/templates/gitlab/gitlab-ad-groups-integration"
GITLAB_AD_GROUPS_FILE_LIST=`cat "${GITLAB_AD_GROUPS_FILE}"`
GITLAB_AD_GROUPS_REFERENCE_FILE="/srv/config/templates/svn/svn-authz-groups"
GITLAB_SCRIPT_LOG_FILE="/srv/config/logs/${HOSTNAME}_gitlab_ad_groups_integration.log"

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [ ! -f "${GITLAB_AD_GROUPS_FILE}" ]; then
  echo -e "\n[ Error ] Missing file ${GITLAB_AD_GROUPS_FILE}\n"
  exit 1
fi

if [ ! -f "${GITLAB_AD_GROUPS_REFERENCE_FILE}" ]; then
  echo -e "\n[ Error ] Missing file ${GITLAB_AD_GROUPS_REFERENCE_FILE}\n"
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
echo "------------------------------"
echo " Gitlab AD Groups Integration "
echo "------------------------------"
echo ""

echo -n > "${GITLAB_SCRIPT_LOG_FILE}"

while read -r ACCOUNT ; do
  [ -z "`echo ${ACCOUNT} | grep '^#'`" ] || continue
  GITLAB_ACCOUNT_NAME=`echo "${ACCOUNT}" | awk '{print $1}'`
  GITLAB_ACCOUNT_GROUPS=`echo "${ACCOUNT}" | awk '{print $NF}' | sed "s|,|\n|g" | sed "s|@||g" | sed "s|=.*||g"`
  echo -e "* Checking if AD groups exists in Gitlab for [ ${GITLAB_ACCOUNT_NAME} ] account..."
  for GROUP in `echo -e "${GITLAB_ACCOUNT_GROUPS}"` ; do
    GROUP_EXIST=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/groups?search="${GROUP}" | python -m json.tool | grep "full_name" | awk -F ":" '{print $2}' | awk -F "\"" '{print $2}' | grep "^${GROUP}$"`
    if [ -z "${GROUP_EXIST}" ] ; then
      GITLAB_GROUP_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups?full_name=${GROUP}&full_path=${GROUP}&lfs_enabled=true&name=${GROUP}&path=${GROUP}&request_access_enabled=false&visibility=private&web_url=${GITLAB_URL}/groups/${GROUP}" | python -m json.tool | grep "\"id\":" | grep -o -E '[0-9]+'`
      echo "  - Group \"${GROUP}\" did not exist. Created with id: ${GITLAB_GROUP_ID}"
      echo "  - Adding users"
      GITLAB_GROUP_USERS=`cat "${GITLAB_AD_GROUPS_REFERENCE_FILE}" | grep "^${GROUP} = " | awk -F "=" '{print $2}' | sed "s| ||g" | sed "s|,|\n|g"`
      for USER in `echo -e "${GITLAB_GROUP_USERS}"` ; do
        #GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?search=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        if [[ -z "${GITLAB_USER_ID}" ]]; then
          LDAP_QUERY=`ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${GITLAB_USER_ACCOUNT}"`
          GITLAB_USER_NAME=`echo "${LDAP_QUERY}" | grep ^cn | sed "s|cn: ||g" | sed "s| |%20|g"`
          GITLAB_USER_EMAIL=`echo "${LDAP_QUERY}" | grep ^mail: | sed "s|.*: ||g"`
          if [ ! -z `echo "${GITLAB_USER_NAME}" | grep "="` ]; then
            GITLAB_USER_NAME=`echo "${GITLAB_USER_NAME}" | base64 --decode > /tmp/.gitlab_user_name.tmp`
            GITLAB_USER_NAME=`cat /tmp/.gitlab_user_name.tmp | sed "s| |%20|g"`
          fi
          if [ ! -z `echo "${GITLAB_USER_EMAIL}" | grep "="` ]; then
            GITLAB_USER_EMAIL=`echo "${GITLAB_USER_EMAIL}" | base64 --decode > /tmp/.gitlab_user_email.tmp`
            GITLAB_USER_EMAIL=`cat /tmp/.gitlab_user_email.tmp | sed "s| ||g"`
          fi
          if [ -z "${GITLAB_USER_EMAIL}" ]; then
            GITLAB_USER_EMAIL="${GITLAB_USER_ACCOUNT}@local"
          fi
          echo "Creating new user - Account: ${GITLAB_USER_ACCOUNT} / Name: ${GITLAB_USER_NAME} / Email: ${GITLAB_USER_EMAIL}" >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
          curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/users?username=${GITLAB_USER_ACCOUNT}&name=${GITLAB_USER_NAME}&email=${GITLAB_USER_EMAIL}&password=venturus&skip_confirmation=true" | python -m json.tool >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
          sleep 3
        fi
        echo "Adding user \"${USER} (${GITLAB_USER_ID})\" to group \"${GROUP} (${GITLAB_GROUP_ID})\"" >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups/${GITLAB_GROUP_ID}/members?user_id=${GITLAB_USER_ID}&access_level=30" | python -m json.tool >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
      done
      echo "  - Done!"
    else
      GITLAB_GROUP_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?search=${GROUP}" | python -m json.tool | grep -oP "full_name.*${GROUP}\"|id.*" | grep -A2 "${GROUP}" | grep "id" | grep -o -E '[0-9]+' | head -n 1`
      GITLAB_GROUP_USERS=`cat "${GITLAB_AD_GROUPS_REFERENCE_FILE}" | grep "^${GROUP} = " | awk -F "=" '{print $2}' | sed "s| ||g" | sed "s|,|\n|g" | sort -u`
      GITLAB_GROUP_MEMBERS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/groups/${GITLAB_GROUP_ID}/members?per_page=100 | python -m json.tool | grep "username" | awk -F ":" '{print $2}' | sed "s| \"||g" | sed "s|\",||g" | sort -u`
      echo "  - Group \"${GROUP}\" already exists"
      echo "  - Checking users"  
      #echo "Gitlab Group Users:"
      #echo -e "${GITLAB_GROUP_USERS}"
      #echo "Gitlab Group Members:"
      #echo -e "${GITLAB_GROUP_MEMBERS}"
      GITLAB_USERS_TO_BE_ADDED=`diff --suppress-common-lines <(echo "${GITLAB_GROUP_USERS}") <(echo "${GITLAB_GROUP_MEMBERS}") | grep "^<" | sed "s|< ||g"`
      GITLAB_USERS_TO_BE_REMOVED=`diff --suppress-common-lines <(echo "${GITLAB_GROUP_USERS}") <(echo "${GITLAB_GROUP_MEMBERS}") | grep "^>" | sed "s|> ||g"`
      for USER in `echo -e "${GITLAB_USERS_TO_BE_ADDED}"` ; do
        #GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?search=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        if [[ -z "${GITLAB_USER_ID}" ]]; then
          GITLAB_USER_ACCOUNT="${USER}"
          LDAP_QUERY=`ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${GITLAB_USER_ACCOUNT}"`
          GITLAB_USER_NAME=`echo "${LDAP_QUERY}" | grep ^cn | sed "s|cn: ||g" | sed "s| |%20|g"`
          GITLAB_USER_EMAIL=`echo "${LDAP_QUERY}" | grep ^mail: | sed "s|.*: ||g"`
          if [ ! -z `echo "${GITLAB_USER_NAME}" | grep "="` ]; then
            GITLAB_USER_NAME=`echo "${GITLAB_USER_NAME}" | base64 --decode > /tmp/.gitlab_user_name.tmp`
            GITLAB_USER_NAME=`cat /tmp/.gitlab_user_name.tmp | sed "s| |%20|g"`
          fi
          if [ ! -z `echo "${GITLAB_USER_EMAIL}" | grep "="` ]; then
            GITLAB_USER_EMAIL=`echo "${GITLAB_USER_EMAIL}" | base64 --decode > /tmp/.gitlab_user_email.tmp`
            GITLAB_USER_EMAIL=`cat /tmp/.gitlab_user_email.tmp | sed "s| ||g"`
          fi
          if [ -z "${GITLAB_USER_EMAIL}" ]; then
            GITLAB_USER_EMAIL="${GITLAB_USER_ACCOUNT}@local"
          fi
          echo "Creating new user - Account: ${GITLAB_USER_ACCOUNT} / Name: ${GITLAB_USER_NAME} / Email: ${GITLAB_USER_EMAIL}" >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
          curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/users?username=${GITLAB_USER_ACCOUNT}&name=${GITLAB_USER_NAME}&email=${GITLAB_USER_EMAIL}&password=venturus&skip_confirmation=true" | python -m json.tool >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
          sleep 3
        fi
        echo "Adding user \"${USER} (${GITLAB_USER_ID})\" to group \"${GROUP} (${GITLAB_GROUP_ID})\"" >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups/${GITLAB_GROUP_ID}/members?user_id=${GITLAB_USER_ID}&access_level=30" | python -m json.tool >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
      done
      for USER in `echo -e "${GITLAB_USERS_TO_BE_REMOVED}"` ; do
        #GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?search=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        GITLAB_USER_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?username=$USER | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        echo "Removing user \"${USER}\" from group \"${GROUP}\"" >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X DELETE "${GITLAB_API_URL}/groups/${GITLAB_GROUP_ID}/members/${GITLAB_USER_ID}"  >>${GITLAB_SCRIPT_LOG_FILE} 2>>${GITLAB_SCRIPT_LOG_FILE}
      done
      echo "  - Done!"
    fi
  done
done <<< "${GITLAB_AD_GROUPS_FILE_LIST}"

echo ""

source /srv/config/templates/svn/properties.cfg

MESSAGE=`cat ${GITLAB_SCRIPT_LOG_FILE}`

if [ -z "${MESSAGE}" ]; then
  MESSAGE="No changes"
  exit 0
fi

/srv/config/install/sendemail/sendEmail.pl -f "devops@local" -t $script_emails_devops -u "[DevOps] Gitlab Permissions: $HOSTNAME" -m "$MESSAGE" -s "webmail.local"

echo -e "\nCompleted!\n"
