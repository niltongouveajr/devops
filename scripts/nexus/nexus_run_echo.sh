#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

NEXUS_API_URL="https://nexus.local/service/rest/v1/script"
NEXUS_USER="admin"
NEXUS_PASS="<pass>"
NEXUS_ECHO_MESSAGE="$1"

# Conditions

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <echo_message>\n"
  exit 1
fi

# Run

curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X POST --header 'Content-Type: text/plain' ${NEXUS_API_URL}/echo/run -d "${NEXUS_ECHO_MESSAGE}"
