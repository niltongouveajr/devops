#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

JIRA_CLI="/srv/config/tools/jira-cli/8.3.0/jira.sh"
JIRA_GROUP="Acesso_DevOps"
JIRA_ROLE="Users"

# Run

for KEY in `${JIRA_CLI} --action getProjectList | awk -F "," '{print $1}' | egrep ^\" | egrep -v \"Key\" | sed "s|\"||g"` ; do
  echo "Project: ${KEY} - Adding group '${JIRA_GROUP}' in role '${JIRA_ROLE}'"
  ${JIRA_CLI} --action addProjectRoleActors --project "${KEY}" --role "${JIRA_ROLE}" --group "${JIRA_GROUP}"
done
