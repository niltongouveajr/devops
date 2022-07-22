#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

JIRA_CLI="/srv/config/tools/jira-cli/8.3.0/jira.sh"

# Run

for KEY in `${JIRA_CLI} --action getProjectList | awk -F "," '{print $1}' | egrep ^\" | egrep -v \"Key\" | sed "s|\"||g"` ; do
  JIRA_LEAD=`${JIRA_CLI} --action getProject --project "${KEY}" | grep ^Lead | awk '{print $NF}'`
  echo "Project: ${KEY} - Lead: ${JIRA_LEAD}"
  ${JIRA_CLI} --action createIssue --issueType "Project Status" --project "${KEY}"  --summary "Project Status" --assignee "${JIRA_LEAD}"
done
