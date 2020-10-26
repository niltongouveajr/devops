#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

NEXUS_API_URL="https://nexus.local/service/rest/v1/script"
NEXUS_USER="admin"
NEXUS_PASS="<pass>"
NEXUS_SCRIPT_NAME="$1"

# Run

echo -e "$(curl --silent --insecure --user ${NEXUS_USER}:${NEXUS_PASS} -X GET ${NEXUS_API_URL}/${NEXUS_SCRIPT_NAME})"
