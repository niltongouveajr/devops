#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

JENKINS_JOB="$1"
JENKINS_AUTH="<user:pass>"
JENKINS_URL="https://jenkins.domain.local/job/${JENKINS_JOB}/lastBuild/api/json"

# Run

curl --silent --insecure --user "${JENKINS_AUTH}" -X GET "${JENKINS_URL}" | python -m json.tool | grep "result" | awk -F "\"" '{print $4}'
