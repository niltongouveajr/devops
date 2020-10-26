#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

NEXUS_API_URL="https://nexus.local/service/rest/v1/script"
NEXUS_USER="admin"
NEXUS_PASS="<pass>"
NEXUS_SCRIPT_NAME="$1"
NEXUS_SCRIPT_FILE="$2"

# Conditions

if [[ $# -ne 2 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <script_name> json/<script_file>.json\n"
  exit 1
fi

# Run

curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X PUT --header 'Content-Type: application/json' ${NEXUS_API_URL}/${NEXUS_SCRIPT_NAME} -d @${NEXUS_SCRIPT_FILE}
