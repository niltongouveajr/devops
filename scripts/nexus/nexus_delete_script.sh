#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

NEXUS_API_URL="https://nexus.local/service/rest/v1/script"
NEXUS_USER="admin"
NEXUS_PASS="<pass>"
NEXUS_SCRIPT_NAME="$1"

# Conditions

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <script_name>\n"
  exit 1
fi

# Run

echo ""
echo -n "Are you sure to delete the script '${NEXUS_SCRIPT_NAME}'? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" == "Y" ]] || [[ "${CONFIRM}" == "y" ]]; then
  echo -e "$(curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X DELETE ${NEXUS_API_URL}/${NEXUS_SCRIPT_NAME})" 
  echo -e "$(curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X GET ${NEXUS_API_URL})"
else
  echo -e "\nAborted.\n"
  exit 0
fi
