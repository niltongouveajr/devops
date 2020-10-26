#!/bin/bash

# Author: Nilton R Gouvea Junior

# Variables

CURRENT_MONTH=`date +%Y-%m-`
LAST_MONTH1=`date +%Y-%m- --date='-1 month'`
LAST_MONTH2=`date +%Y-%m- --date='-2 month'`

GITLAB_SCRIPT_DIR="/srv/config/scripts/gitlab"
GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_ACTIVE_REPOS=`cat ${GITLAB_SCRIPT_DIR}/gitlab_last_commits.log | grep -e ${CURRENT_MONTH} -e ${LAST_MONTH1} -e ${LAST_MONTH2} | awk '{print $2}' | sort -u`
GITLAB_ACTIVE_REPOS_FORMATTED=`echo -e "${GITLAB_ACTIVE_REPOS}" | sed "s|/|%2F|g" | sed "s|.git||g"`

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo -e "
[ Error ] Invalid number of parameter.

Usage: $0 <--log|--jenkins|--nojenkins|--ci|--noci|--repos|--projects>

--log		Show full log including information about repositories with Jenkins integration and projects with CI integration
--jenkins	Show number of repositories with Jenkins integration in Gitlab
--nojenkins	Show number of repositories without Jenkins integration in Gitlab
--ci		Show number of projects with Continuous Integration (CI) in Gitlab
--noci		Show number of projects without Continuous Integration (CI) in Gitlab
--repos		Show total number of repositories in Gitlab
--projects	Show total number of repositories in Gitlab

All information is considering only repositories/projects in Gitlab with activity in last 3 months.
"

  exit 1
fi

# Run

#############################################
### REPOSITORIES WITH JENKINS INTEGRATION ###
#############################################

function REPOS_WITH_JENKINS()
{
  GITLAB_REPOS_WITH_JENKINS=$(
  for REPO in `echo -e "${GITLAB_ACTIVE_REPOS_FORMATTED}"` ; do
    GITLAB_REPO_UNFORMATTED=`echo ${REPO} | sed "s|%2F|/|g"`
    GITLAB_REPO_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${REPO}" | python -m json.tool | grep "\"id\"" | head -n 1 | sed "s|[^0-9]*||g"`
    GITLAB_JENKINS_INTEGRATION=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/hooks" | python -m json.tool | grep url | grep jenkins | sed "s|.*http|http|g" | sed "s|\".*||g"`
    if [[ ! -z "${GITLAB_JENKINS_INTEGRATION}" ]]; then
      echo "${GITLAB_REPO_UNFORMATTED} (${GITLAB_REPO_ID})"
      #echo "${GITLAB_JENKINS_INTEGRATION}"
      #echo ""
    fi
  done
  )
  GITLAB_REPOS_WITH_JENKINS_TOTAL=`echo -e "${GITLAB_REPOS_WITH_JENKINS}" | wc -l`
}

################################################
### REPOSITORIES WITHOUT JENKINS INTEGRATION ###
################################################

function REPOS_WITHOUT_JENKINS()
{
  GITLAB_REPOS_WITHOUT_JENKINS=$(
  for REPO in `echo -e "${GITLAB_ACTIVE_REPOS_FORMATTED}"` ; do
    GITLAB_REPO_UNFORMATTED=`echo ${REPO} | sed "s|%2F|/|g"`
    GITLAB_REPO_ID=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${REPO}" | python -m json.tool | grep "\"id\"" | head -n 1 | sed "s|[^0-9]*||g"`
    GITLAB_JENKINS_INTEGRATION=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/hooks" | python -m json.tool | grep url | grep jenkins | sed "s|.*http|http|g" | sed "s|\".*||g"`
    if [[ -z "${GITLAB_JENKINS_INTEGRATION}" ]]; then
      echo "${GITLAB_REPO_UNFORMATTED} (${GITLAB_REPO_ID})"
    fi
  done
  )
  GITLAB_REPOS_WITHOUT_JENKINS_TOTAL=`echo -e "${GITLAB_REPOS_WITHOUT_JENKINS}" | wc -l`
}

##########################
### REPOSITORIES TOTAL ###
##########################

function REPOS_TOTAL()
{
  GITLAB_REPOS_TOTAL=`echo -e "${GITLAB_ACTIVE_REPOS}" | wc -l`
}

########################
### PROJECTS WITH CI ###
########################

function PROJECTS_WITH_CI()
{
  GITLAB_PROJECTS_WITH_CI=`echo -e "${GITLAB_REPOS_WITH_JENKINS}" | awk -F "/" '{print $1"/"$2}' | sed "s| .*||g" | grep "^[a-z]" | sort -u` 
  GITLAB_PROJECTS_WITH_CI_TOTAL=`echo -e "${GITLAB_PROJECTS_WITH_CI}" | wc -l`
}

###########################
### PROJECTS WITHOUT CI ###
###########################

function PROJECTS_WITHOUT_CI()
{
  GITLAB_PROJECTS_WITHOUT_CI_PREPARE=`echo -e "${GITLAB_REPOS_WITHOUT_JENKINS}" | awk -F "/" '{print $1"/"$2}' | sed "s| .*||g" | grep "^[a-z]" | sort -u` 
  GITLAB_PROJECTS_WITHOUT_CI=`comm -3 <(echo "$GITLAB_PROJECTS_WITHOUT_CI_PREPARE") <(echo "$GITLAB_PROJECTS_WITH_CI") | grep "^[a-z]" | sort -u`
  GITLAB_PROJECTS_WITHOUT_CI_TOTAL=`echo -e "${GITLAB_PROJECTS_WITHOUT_CI}" | wc -l`
}

######################
### PROJECTS TOTAL ###
######################

function PROJECTS_TOTAL()
{
  GITLAB_PROJECTS_TOTAL=`echo "${GITLAB_PROJECTS_WITH_CI_TOTAL}+${GITLAB_PROJECTS_WITHOUT_CI_TOTAL}" | bc`
}

############
### LOGS ###
############

function LOG_ALL()
{
  REPOS_WITH_JENKINS
  REPOS_WITHOUT_JENKINS
  REPOS_TOTAL
  PROJECTS_WITH_CI
  PROJECTS_WITHOUT_CI
  PROJECTS_TOTAL

  echo ""
  echo "---------------------------------------"
  echo " REPOSITORIES WITH JENKINS INTEGRATION "
  echo "---------------------------------------"
  echo ""
  echo "${GITLAB_REPOS_WITH_JENKINS}"
  echo ""
  echo "------------------------------------------"
  echo " REPOSITORIES WITHOUT JENKINS INTEGRATION "
  echo "------------------------------------------"
  echo ""
  echo "${GITLAB_REPOS_WITHOUT_JENKINS}"
  echo ""
  echo "------------------"
  echo " PROJECTS WITH CI "
  echo "------------------"
  echo ""
  echo "${GITLAB_PROJECTS_WITH_CI}"
  echo ""
  echo "---------------------"
  echo " PROJECTS WITHOUT CI "
  echo "---------------------"
  echo ""
  echo "${GITLAB_PROJECTS_WITHOUT_CI}"
  echo ""
  echo "---------"
  echo " SUMMARY "
  echo "---------"
  echo ""
  echo "Repositories with Jenkins: ${GITLAB_REPOS_WITH_JENKINS_TOTAL}"
  echo "Repositories without Jenkins: ${GITLAB_REPOS_WITHOUT_JENKINS_TOTAL}"
  echo "Repositories Total: ${GITLAB_REPOS_TOTAL}"
  echo "Projects with CI: ${GITLAB_PROJECTS_WITH_CI_TOTAL}"
  echo "Projects without CI: ${GITLAB_PROJECTS_WITHOUT_CI_TOTAL}"
  echo "Projects Total: ${GITLAB_PROJECTS_TOTAL}"
  echo ""
}

function LOG_REPOS_WITH_JENKINS()
{
  REPOS_WITH_JENKINS
  echo "${GITLAB_REPOS_WITH_JENKINS_TOTAL}"
}

function LOG_REPOS_WITHOUT_JENKINS()
{
  REPOS_WITHOUT_JENKINS
  echo "${GITLAB_REPOS_WITHOUT_JENKINS_TOTAL}"
}

function LOG_REPOS_TOTAL()
{
  REPOS_TOTAL
  echo "${GITLAB_REPOS_TOTAL}"
}

function LOG_PROJECTS_WITH_CI()
{
  REPOS_WITH_JENKINS
  PROJECTS_WITH_CI
  echo "${GITLAB_PROJECTS_WITH_CI_TOTAL}"
}

function LOG_PROJECTS_WITHOUT_CI()
{
  REPOS_WITH_JENKINS
  REPOS_WITHOUT_JENKINS
  PROJECTS_WITH_CI
  PROJECTS_WITHOUT_CI
  PROJECTS_TOTAL
  echo "${GITLAB_PROJECTS_WITHOUT_CI_TOTAL}"
}

function LOG_PROJECTS_TOTAL()
{
  REPOS_WITH_JENKINS
  REPOS_WITHOUT_JENKINS
  PROJECTS_WITH_CI
  PROJECTS_WITHOUT_CI
  PROJECTS_TOTAL
  echo "${GITLAB_PROJECTS_TOTAL}"
}

#######################
### PARAMETRIZATION ###
#######################

if [[ $1 == "--log" ]]; then
  LOG_ALL
elif [[ $1 == "--jenkins" ]]; then
  LOG_REPOS_WITH_JENKINS
elif [[ $1 == "--nojenkins" ]]; then
  LOG_REPOS_WITHOUT_JENKINS
elif [[ $1 == "--ci" ]]; then
  LOG_PROJECTS_WITH_CI
elif [[ $1 == "--noci" ]]; then
  LOG_PROJECTS_WITHOUT_CI
elif [[ $1 == "--repos" ]]; then
  LOG_REPOS_TOTAL
elif [[ $1 == "--projects" ]]; then
  LOG_PROJECTS_TOTAL
else
  echo -e "
[ Error ] Invalid parameter.

Usage: $0 <--log|--jenkins|--nojenkins|--ci|--noci|--repos|--projects>

--log		Show full log including information about repositories with Jenkins integration and projects with CI
--jenkins	Show number of repositories with Jenkins integration
--nojenkins	Show number of repositories without Jenkins integration
--ci		Show number of projects with Continuous Integration (CI)
--noci		Show number of projects without Continuous Integration (CI)
--repos		Show total number of repositories
--projects	Show total number of repositories

All information is considering only repositories/projects in Gitlab with activity in last 3 months.
"

  exit 1
fi
