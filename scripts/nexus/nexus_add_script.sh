#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

NEXUS_API_URL="https://nexus.local/service/rest/v1/script"
NEXUS_USER="admin"
NEXUS_PASS="<pass>"
NEXUS_SCRIPT_FILE="$1"

# Conditions

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 json/<script_file>.json\n"
  exit 1
fi

# Run

curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X POST --header 'Content-Type: application/json' ${NEXUS_API_URL} -d @${NEXUS_SCRIPT_FILE}

echo -e "$(curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X GET ${NEXUS_API_URL})"
