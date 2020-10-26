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

if [[ $# -gt 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <project-name|optional>\n"
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
echo "--------------------------------"
echo " Gitlab Projects Services: Jira "
echo "--------------------------------"
echo ""

GITLAB_PROJECT_PAGES=`curl --silent --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/projects | grep "^X-Total-Pages" | sed 's/[^0-9]*//g'`
COUNTER=1
while [ $COUNTER -le ${GITLAB_PROJECT_PAGES} ];do
  for GITLAB_PROJECT_ID in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?page=${COUNTER}" | python -m json.tool  | egrep "http_url_to_repo|\"id\"" | sed "s|            .*||g" | egrep "\"id\"" | grep -o -E '[0-9]+'` ; do
    GITLAB_PROJECT_NAME=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
    GITLAB_PROJECT_SERVICES_JIRA=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/services/jira" | python -m json.tool #| grep "\"" | sed "s|\"||g" | sed "s|,||g" | sed "s| ||g"`
    LIST_ONLY="0"
    if [[ "${LIST_ONLY}" == "1" ]]; then
      echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})"
      echo "${GITLAB_PROJECT_SERVICES_JIRA}"
      echo ""
    else
      if [[ ! -z `echo "${GITLAB_PROJECT_SERVICES_JIRA}" | grep "https://jira.local"` ]]; then 
        echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})"
        echo ""
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/services/jira?url=http://jira.local:8080&username=vntprojhud&password=dEv0p\$vNt" | python -m json.tool
        echo ""
      fi
      if [[ ! -z `echo "${GITLAB_PROJECT_SERVICES_JIRA}" | grep "https://jira2.local"` ]]; then 
        echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})"
        echo ""
        curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/services/jira?url=http://jira2.local:8080&username=vntprojhud&password=dEv0p\$vNt" | python -m json.tool
        echo ""
      fi
    fi
  done
  (( COUNTER++ ))
done
