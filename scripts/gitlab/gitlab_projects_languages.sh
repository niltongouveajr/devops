#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_SCRIPT_LOG_FILE="/srv/config/logs/${HOSTNAME}_gitlab_projects_languages.log"
GITLAB_SCRIPT_LOG_FILE_SUMMARY="/srv/config/logs/${HOSTNAME}_gitlab_projects_languages_summary.log"

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
echo "---------------------------"
echo " Gitlab Projects Languages "
echo "---------------------------"
echo ""

echo -n > ${GITLAB_SCRIPT_LOG_FILE}

if [ $# -eq 1 ]; then
  GITLAB_PROJECT_ID_SEARCH=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?search=$1" | python -m json.tool | grep "\"id\"" | sed "s|            .*||g" | grep -o -E '[0-9]+'`
  for GITLAB_PROJECT_ID in `echo -e "${GITLAB_PROJECT_ID_SEARCH}"` ; do
    GITLAB_PROJECT_NAME=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
    GITLAB_PROJECT_LANGUAGES=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/languages" | python -m json.tool | grep "\"" | sed "s|\"||g" | sed "s|,||g" | sed "s| ||g"`
    echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})"
    echo "${GITLAB_PROJECT_LANGUAGES}"
    echo ""
    echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})" >> "${GITLAB_SCRIPT_LOG_FILE}"
    echo "${GITLAB_PROJECT_LANGUAGES}" >> "${GITLAB_SCRIPT_LOG_FILE}"
    echo "" >> "${GITLAB_SCRIPT_LOG_FILE}"
  done
else
  GITLAB_PROJECT_PAGES=`curl --silent --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/projects | grep "^X-Total-Pages" | sed 's/[^0-9]*//g'`
  COUNTER=1
  while [ $COUNTER -le ${GITLAB_PROJECT_PAGES} ];do
    for GITLAB_PROJECT_ID in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?page=${COUNTER}" | python -m json.tool  | egrep "http_url_to_repo|\"id\"" | sed "s|            .*||g" | egrep "\"id\"" | grep -o -E '[0-9]+'` ; do
      GITLAB_PROJECT_NAME=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
      GITLAB_PROJECT_LANGUAGES=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/languages" | python -m json.tool | grep "\"" | sed "s|\"||g" | sed "s|,||g" | sed "s| ||g"`
      echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})"
      echo "${GITLAB_PROJECT_LANGUAGES}"
      echo ""
      echo "${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID})" >> "${GITLAB_SCRIPT_LOG_FILE}"
      echo "${GITLAB_PROJECT_LANGUAGES}" >> "${GITLAB_SCRIPT_LOG_FILE}"
      echo "" >> "${GITLAB_SCRIPT_LOG_FILE}"
    done
    (( COUNTER++ ))
  done
fi

# Languages Summary

echo -n > ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}

LANGUAGES_NAMES=`cat "${GITLAB_SCRIPT_LOG_FILE}" | grep -v "^http" | grep -v "^$" | awk -F ":" '{print $1}' | sort -u`
LANGUAGES_PERCENTAGE_TOTAL=`cat "${GITLAB_SCRIPT_LOG_FILE}" | grep -v ^http | grep -v ^$ | awk -F ":" '{print $2}' | sed "s|^\.|0\.|g" | awk '{s+=$1} END {print s}'`

for LANGUAGE in `echo -e "${LANGUAGES_NAMES}"` ; do
  LANGUAGE_SUM=`cat "${GITLAB_SCRIPT_LOG_FILE}" | grep -v "^http" | grep -v "^$" | grep "^${LANGUAGE}:" | awk -F ":" '{print $2}' | sed "s|^\.|0\.|g" | awk '{s+=$1} END {print s}'`
  LANGUAGE_PERCENTAGE=`echo "scale=4; (${LANGUAGE_SUM}*100)/${LANGUAGES_PERCENTAGE_TOTAL}" | bc`
  echo "${LANGUAGE}:${LANGUAGE_PERCENTAGE}" | sed "s|:\.|:0\.|g" >> ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}
done

cat ${GITLAB_SCRIPT_LOG_FILE_SUMMARY} | sort -t$':' -k2 -nr > ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}.tmp
mv ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}.tmp ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}
sed -i '/^message/d' ${GITLAB_SCRIPT_LOG_FILE_SUMMARY}

echo -e "\nLanguages Summary:\n" ; cat ${GITLAB_SCRIPT_LOG_FILE_SUMMARY} ; echo -e "\nProjects Languages:\n" ; cat ${GITLAB_SCRIPT_LOG_FILE}

echo -e "\nCompleted!\n"
