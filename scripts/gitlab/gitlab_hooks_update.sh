#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_HOOK_TEMPLATE_PRE="/srv/config/hooks/gitlab-hooks/template/custom_hooks/pre-receive"
GITLAB_HOOK_TEMPLATE_POST="/srv/config/hooks/gitlab-hooks/template/custom_hooks/post-receive"
GITLAB_HOOKS=`find /srv/gitlab/git-data/repositories -type f -name pre-receive | sort`

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [[ "${HOSTNAME}" != "sd-gitlab01" ]] && [[ "${HOSTNAME}" != "sd-gitlab02" ]]  && [[ "${HOSTNAME}" != "sd-gitlab03" ]]; then
  echo -e "\n[ Error ] Invalid hostname. Run in 'sd-gitlab01', 'sd-gitlab02' or 'sd-gitlab03'.\n"
  exit 1
fi

if [ ! -f "${GITLAB_HOOK_TEMPLATE_PRE}" ]; then
  echo -e "\n[ Error ] Missing file ${GITLAB_HOOK_TEMPLATE_PRE}\n"
  exit 1
fi

if [ ! -f "${GITLAB_HOOK_TEMPLATE_POST}" ]; then
  echo -e "\n[ Error ] Missing file ${GITLAB_HOOK_TEMPLATE_POST}\n"
  exit 1
fi

# Header

echo ""
echo "---------------------"
echo " Gitlab Hooks Update "
echo "---------------------"
echo ""

echo -n "This script will change hook (pre-receive and post-receive) for all repositories based on a templates. Are you sure you want run it? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" != "Y" ]] && [[ "${CONFIRM}" != "y" ]]; then
  echo -e "\nAborted.\n"
  exit 0
fi

echo -e "\nUpdating hooks...\n"
sleep 3

# Run

for HOOK in `echo -e "${GITLAB_HOOKS}"`; do
  echo "${HOOK}" | sed "s|/pre-receive||g"
  HOOK_DIR=`echo "${HOOK}" | sed "s|pre-receive$||g"`
  if [[ -f "${GITLAB_HOOK_TEMPLATE_PRE}" ]] && [[ -d "${HOOK_DIR}" ]]; then
    cd "${HOOK_DIR}"
    cp -pr "${GITLAB_HOOK_TEMPLATE_PRE}" "${HOOK_DIR}/pre-receive-new"
    JIRA_STATUS=`cat ${HOOK_DIR}/pre-receive | grep "^JIRA="` 
    JIRA_KEY=`cat ${HOOK_DIR}/pre-receive | grep "^jirakey="`
    if [[ ! -z "${JIRA_STATUS}" ]]; then
      sed -i "s|^JIRA=.*|${JIRA_STATUS}|g" "${HOOK_DIR}/pre-receive-new"
    fi 
    if [[ ! -z "${JIRA_KEY}" ]]; then
      sed -i "s|^jirakey=.*|${JIRA_KEY}|g" "${HOOK_DIR}/pre-receive-new"
    fi 
    mv "${HOOK_DIR}/pre-receive-new" "${HOOK_DIR}/pre-receive"
    chown git:git "${HOOK_DIR}/pre-receive"
  fi
  if [[ -f "${GITLAB_HOOK_TEMPLATE_POST}" ]] && [[ -d "${HOOK_DIR}" ]]; then
    cd "${HOOK_DIR}"
    cp -pr "${GITLAB_HOOK_TEMPLATE_POST}" "${HOOK_DIR}/post-receive"
    chown git:git "${HOOK_DIR}/post-receive"
  fi
done
