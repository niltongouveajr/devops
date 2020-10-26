#!/bin/bash

# Author: Nilton R Gouvea Junior

######################
### Main Variables ###
######################

CUSTOMER="${1}"
DOCKER_INSTALL="${2}"
GITLAB_INSTALL="${3}"
JENKINS_INSTALL="${4}"
JIRA_INSTALL="${5}"
RANCHER_INSTALL="${6}"
SONAR_INSTALL="${7}"
TPP="${8}"
TPP_CUSTOMER="${9}"
TPP_PROJECT="${10}"

TPP_ADD_URL="https://<user:pass>@devops.local/tpp/add.php"
AD_GROUPS_FILE="/srv/config/templates/gitlab/gitlab-ad-groups-integration"
AD_GROUPS_USERS_FILE="/srv/config/templates/svn/svn-authz-groups"

########################
### Docker Variables ###
########################

DOCKER_HOSTED_PORT="${11}"
DOCKER_GROUP_PORT="${12}"
DOCKER_AD_GROUP="${13}"
DOCKER_CUSTOMER_FULL_NAME="${14}"

DOCKER_API_ENDPOINT="https://docker.local/service/rest/v1"
DOCKER_API_URL="${DOCKER_API_ENDPOINT}/script"
DOCKER_USER="admin"
DOCKER_PASS="<pass>"
DOCKER_JSON_DIR="/srv/config/scripts/nexus/json"
DOCKER_BLOBSTORE="$(curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X GET ${DOCKER_API_ENDPOINT}/blobstores/${CUSTOMER}/quota-status)"
DOCKER_REPOSITORIES="$(curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X GET ${DOCKER_API_ENDPOINT}/repositories | grep "name" | awk -F "\"" '{print $4}' | sort -u)"
DOCKER_HOSTED_PORT_CHECK="$(curl --silent --insecure --head https://docker.local:${DOCKER_HOSTED_PORT} | head -n 1 | cut -d ' ' -f 2)"
DOCKER_GROUP_PORT_CHECK="$(curl --silent --insecure --head https://docker.local:${DOCKER_GROUP_PORT} | head -n 1 | cut -d ' ' -f 2)"

########################
### Gitlab Variables ###
########################

GITLAB_TEMPLATE="${15}"
GITLAB_PROJECT_GROUP="${16}"
GITLAB_REPO="${17}"

GITLAB_API_URL="https://gitlab.local/api/v4"
GITLAB_TOKEN="<token>"
GITLAB_INTEGRATION_USER="<user>"
GITLAB_INTEGRATION_PASS="<pass>"
GITLAB_INTEGRATION_EMAIL="<user>@local"
GITLAB_TRY_ACCESS=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups"`
GITLAB_CUSTOMER_GROUP="${CUSTOMER}"
GITLAB_AVAILABLE_GROUPS=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?per_page=100" | python -m json.tool | grep \"name\" | sed "s|^.*: \"||g" | sed "s|\",.*||g" | sort`
GITLAB_AVAILABLE_PROJECTS=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?per_page=100" | python -m json.tool | grep "path_with_namespace" | sed "s|.*: \"||g" | sed "s|\",||g" | sort`
GITLAB_AVAILABLE_PROJECTS_PAGES=`curl --silent --insecure --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/projects | grep "^X-Total-Pages" | sed 's/[^0-9]*//g'`
GITLAB_REPO_DIR="/srv/gitlab/repos/${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}.git"
GITLAB_HOOKS_TEMPLATE_DIR="/srv/config/hooks/gitlab-hooks/template/custom_hooks"
GITLAB_TEMPLATE_DIR=`echo "${GITLAB_TEMPLATE}" | xargs basename | sed "s|.git||g"`
GITLAB_WORK_DIR="/tmp"
GITLAB_PROJECT_URL="https://gitlab.local/${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}"

#########################
### Jenkins Variables ###
#########################

JENKINS_JOB_NAME="${18}"
JENKINS_JOB_VIEW="${19}"
JENKINS_JOB_REPO="${20}"
JENKINS_JOB_CUSTOMER="${21}"
JENKINS_JOB_TYPE="${22}"
JENKINS_JOB_CONTACT="${23}"
JENKINS_JOB_NOTES="${24}"

JENKINS_URL="https://jenkins.local"
JENKINS_TEMPLATE="template_pipeline_gitlab"
JENKINS_TOKEN="<user:<pass>"
JENKINS_WORK_DIR="/tmp"
JENKINS_PROJECT_URL="https://jenkins.local/job/${JENKINS_JOB_NAME}"

######################
### Jira Variables ###
######################

JIRA_KEY="${25}"
JIRA_TEMPLATE="${26}"
JIRA_CUSTOMER_ALIAS="${27}"
JIRA_CUSTOMER_MANAGER_NAME="${28}"
JIRA_PROJECT_MANAGER="${29}"
JIRA_PROJECT="${30}"
JIRA_ISSUE_SCHEMA="${31}"
JIRA_WORKFLOW_SCHEMA="${32}"

JIRACLI_BIN="jira.sh"
JIRACLI_DIR="/srv/config/tools/jira-cli/8.3.0"
JIRA_REST_URL="http://jira.local:8080/rest/api/2"
JIRA_REST_AGILE_URL="http://jira.local:8080/rest/agile/1.0"
JIRA_REST_AUTH="<user>:<pass>"
JIRA_NAME="${JIRA_CUSTOMER_ALIAS} - ${JIRA_PROJECT}"
JIRA_CUSTOMER_MANAGER_ACCOUNT=`ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "cn=${JIRA_CUSTOMER_MANAGER_NAME}*" 2>/dev/null | grep -e ^sAMAccountName | awk '{print $NF}'`
JIRA_PROJECT_URL="https://jira.local/browse/${JIRA_KEY}"

#########################
### Rancher Variables ###
#########################

RANCHER_PROJECT="${33}"
RANCHER_USER="${34}"
RANCHER_TOKEN="${35}"

RANCHER_API_URL="https://rancher.local/v3"
RANCHER_API_USER="<api-user>"
RANCHER_API_PASS="<api-pass>"
RANCHER_CLUSTER="<cluster>"
RANCHER_CLUSTER_ID="<cluster-id>"
RANCHER_SERVER="https://rancher.local/k8s/clusters/${RANCHER_CLUSTER_ID}"
RANCHER_USER="<kubernetes-user>"
RANCHER_TOKEN="<kubernetes-token>"
RANCHER_AVAILABLE_PROJECTS=`curl --silent --insecure --user "${RANCHER_API_USER}:${RANCHER_API_PASS}" -X GET -H "Accept: application/json" -H "Content-Type: application/json" "${RANCHER_API_URL}/projects" | python -m json.tool | grep "\"name\":" | egrep -v "(https|null)" | awk '{print $2}' | sed "s|\"||g" | sed "s|,||g"`
RANCHER_AVAILABLE_NAMESPACES=`/srv/config/tools/rancher/kubectl get namespaces | awk '{print $1}' | grep -v "^NAME$"`
RANCHER_NAMESPACE1="development"
RANCHER_NAMESPACE2="qa"
RANCHER_NAMESPACE3="production"
RANCHER_PROJECT_URL="https://rancher.local/c/${RANCHER_CLUSTER_ID}/projects-namespaces"

#######################
### Sonar Variables ###
#######################

SONAR_KEY="${36}"
SONAR_CUSTOMER="${37}"
SONAR_PROJECT="${38}"

SONAR_USER="admin"
SONAR_PASS="<pass>"
SONAR_API_URL="https://sonar.local/api"
SONAR_PROJECT_URL="https://sonar.local/dashboard?id=${SONAR_KEY}"

#######################
### Other Variables ###
#######################

SCRIPT_USER="${39}"

#############
### Debug ###
#############

DEBUG_PARAMETERS="0"

if [[ "${DEBUG_PARAMETERS}" -eq "1" ]]; then
  echo "1.  CUSTOMER = ${CUSTOMER}"
  echo "2.  DOCKER_INSTALL = ${DOCKER_INSTALL}"
  echo "3.  GITLAB_INSTALL = ${GITLAB_INSTALL}"
  echo "4.  JENKINS_INSTALL = ${JENKINS_INSTALL}"
  echo "5.  JIRA_INSTALL = ${JIRA_INSTALL}"
  echo "6.  RANCHER_INSTALL = ${RANCHER_INSTALL}"
  echo "7.  SONAR_INSTALL = ${SONAR_INSTALL}"
  echo "8.  TPP = ${TPP}"
  echo "9.  TPP_CUSTOMER = ${TPP_CUSTOMER}"
  echo "10. TPP_PROJECT = ${TPP_PROJECT}"
  echo "11. DOCKER_HOSTED_PORT = ${DOCKER_HOSTED_PORT}"
  echo "12. DOCKER_GROUP_PORT = ${DOCKER_GROUP_PORT}"
  echo "13. DOCKER_AD_GROUP = ${DOCKER_AD_GROUP}"
  echo "14. DOCKER_CUSTOMER_FULL_NAME = ${DOCKER_CUSTOMER_FULL_NAME}"
  echo "15. GITLAB_TEMPLATE = ${GITLAB_TEMPLATE}"
  echo "16. GITLAB_PROJECT_GROUP = ${GITLAB_PROJECT_GROUP}"
  echo "17. GITLAB_REPO = ${GITLAB_REPO}"
  echo "18. JENKINS_JOB_NAME = ${JENKINS_JOB_NAME}"
  echo "19. JENKINS_JOB_VIEW = ${JENKINS_JOB_VIEW}"
  echo "20. JENKINS_JOB_REPO = ${JENKINS_JOB_REPO}"
  echo "21. JENKINS_JOB_CUSTOMER = ${JENKINS_JOB_CUSTOMER}"
  echo "22. JENKINS_JOB_TYPE = ${JENKINS_JOB_TYPE}"
  echo "23. JENKINS_JOB_CONTACT = ${JENKINS_JOB_CONTACT}"
  echo "24. JENKINS_JOB_NOTES = ${JENKINS_JOB_NOTES}"
  echo "25. JIRA_KEY = ${JIRA_KEY}"
  echo "26. JIRA_TEMPLATE = ${JIRA_TEMPLATE}"
  echo "27. JIRA_CUSTOMER_ALIAS = ${JIRA_CUSTOMER_ALIAS}"
  echo "28. JIRA_CUSTOMER_MANAGER_NAME = ${JIRA_CUSTOMER_MANAGER_NAME}"
  echo "29. JIRA_PROJECT_MANAGER = ${JIRA_PROJECT_MANAGER}"
  echo "30. JIRA_PROJECT = ${JIRA_PROJECT}"
  echo "31. JIRA_ISSUE_SCHEMA = ${JIRA_ISSUE_SCHEMA}"
  echo "32. JIRA_WORKFLOW_SCHEMA = ${JIRA_WORKFLOW_SCHEMA}"
  echo "33. RANCHER_PROJECT = ${RANCHER_PROJECT}"
  echo "34. RANCHER_USER = ${RANCHER_USER}"
  echo "35. RANCHER_TOKEN = ${RANCHER_TOKEN}"
  echo "36. SONAR_KEY = ${SONAR_KEY}"
  echo "37. SONAR_CUSTOMER = ${SONAR_CUSTOMER}"
  echo "38. SONAR_PROJECT = ${SONAR_PROJECT}"
  echo "39. SCRIPT_USER = ${SCRIPT_USER}"
  exit 0
fi

##########################
### General Conditions ###
##########################

#if [[ ${EUID} -ne 0 ]]; then
#  echo -e "\n[ Error ] This script must be run as root.\n"
#  exit 1
#fi

if [[ "${DOCKER_INSTALL}" == "No" ]] && [[ "${GITLAB_INSTALL}" == "No" ]] && [[ "${JENKINS_INSTALL}" == "No" ]] && [[ "${JIRA_INSTALL}" == "No" ]] && [[ "${RANCHER_INSTALL}" == "No" ]] && [[ "${SONAR_INSTALL}" == "No" ]]; then
  echo -e "\n[ Error ] At least one of the tools must be selected (Docker, Gitlab, Jenkins, Jira, Rancher, Sonar).\n"
  exit 1
fi

if [[ -z "${CUSTOMER}" ]]; then
  echo -e "\n[ Error ] CUSTOMER can not be blank.\n"
  exit 1
fi

if [[ "${CUSTOMER}" == "(empty)" ]]; then
  echo -e "\n[ Error ] CUSTOMER can not be empty.\n"
  exit 1
fi

if [[ ! -f "${AD_GROUPS_FILE}" ]]; then
  echo -e "\n[ Error ] Missing file ${GITLAB_AD_GROUPS_FILE}.\n"
  exit 1
fi

if [[ ! -f "${AD_GROUPS_USERS_FILE}" ]]; then
  echo -e "\n[ Error ] Missing file ${AD_GROUPS_USERS_FILE}.\n"
  exit 1
fi

######################
### TPP Conditions ###
######################

if [[ "${TPP}" == "Yes" ]]; then

  if [[ -z "${TPP_CUSTOMER}" ]] || [[ -z "${TPP_PROJECT}" ]]; then
    echo -e "\n[ Error ] TPP parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${TPP_CUSTOMER}" == "(empty)" ]] || [[ "${TPP_PROJECT}" == "(empty)" ]]; then
    echo -e "\n[ Error ] TPP parameters can not be empty.\n"
    exit 1
  fi

fi

#########################
### Docker Conditions ###
#########################

if [[ "${DOCKER_INSTALL}" == "Yes" ]]; then

  if [[ "${DOCKER_HOSTED_PORT}" == "(empty)" ]] || [[ "${DOCKER_GROUP_PORT}" == "(empty)" ]] || [[ "${DOCKER_AD_GROUP}" == "(empty)" ]] || [[ "${DOCKER_CUSTOMER_NAME}" == "(empty)" ]]; then
    echo -e "\n[ Error ] Docker parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${DOCKER_HOSTED_PORT}" =~ [^0-9] ]]; then
    echo -e "\n[ Error ] Use only numbers for DOCKER_HOSTED_PORT.\n"
    exit 1
  fi

  if [[ "${DOCKER_GROUP_PORT}" =~ [^0-9] ]]; then
    echo -e "\n[ Error ] Use only numbers for DOCKER_GROUP_PORT.\n"
    exit 1
  fi

  if [[ -z `echo "${DOCKER_AD_GROUP}" | grep "^Acesso_"` ]]; then
    echo -e "\n[ Error ] Invalid name for DOCKER_AD_GROUP. Use 'Acesso_<customer>'.\n"
    exit 1
  fi

  if [[ ! -z `echo -e "${DOCKER_BLOBSTORE}"` ]]; then
    echo -e "\n[ Error ] Blobstore '${CUSTOMER}' already exists.\n"
    exit 1
  fi

  if [[ ! -z `echo -e "${DOCKER_REPOSITORIES}" | grep "docker-${CUSTOMER}-hosted"` ]]; then
    echo -e "\n[ Error ] Repository 'docker-${CUSTOMER}-hosted' already exists.\n"
    exit 1
  fi

  if [[ ! -z `echo -e "${DOCKER_REPOSITORIES}" | grep "docker-${CUSTOMER}-group"` ]]; then
    echo -e "\n[ Error ] Repository 'docker-${CUSTOMER}-group' already exists.\n"
    exit 1
  fi

  if [[ "${DOCKER_HOSTED_PORT_CHECK}" == "400" ]]; then
    echo -e "\n[ Error ] DOCKER_HOSTED_PORT '${DOCKER_HOSTED_PORT}' already in use.\n"
    exit 1
  fi
 
  if [[ "${DOCKER_GROUP_PORT_CHECK}" == "400" ]]; then
    echo -e "\n[ Error ] DOCKER_GROUP_PORT '${DOCKER_GROUP_PORT}' already in use.\n"
    exit 1
  fi

fi

#########################
### Gitlab Conditions ###
#########################

if [[ "${GITLAB_INSTALL}" == "Yes" ]]; then

  if [[ -z "${GITLAB_TEMPLATE}" ]] || [[ -z "${GITLAB_PROJECT_GROUP}" ]] || [[ -z "${GITLAB_REPO}" ]]; then
    echo -e "\n[ Error ]  Gitlab parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${GITLAB_PROJECT_GROUP}" == "(empty)" ]] || [[ "${GITLAB_REPO}" == "(empty)" ]]; then
    echo -e "\n[ Error ]  Gitlab parameters can not be empty.\n"
    exit 1
  fi

  if [[ "${GITLAB_PROJECT_GROUP}" =~ [^a-z0-9-_] ]]; then
    echo -e "\n[ Error ] Special characters are not allowed for GITLAB_PROJECT_GROUP.\n"
    exit 1
  fi

  if [[ ! -z `echo "${GITLAB_PROJECT_GROUP}" | grep "[A-Z]"` ]]; then
    echo -e "\n[ Error ] Use only lowercase characters for GITLAB_PROJECT_GROUP.\n"
    exit 1
  fi

  if [[ "${GITLAB_REPO}" =~ [^a-z0-9-_] ]]; then
    echo -e "\n[ Error ] Special characters are not allowed for GITLAB_REPO.\n"
    exit 1
  fi

  if [[ ! -z `echo "${GITLAB_REPO}" | grep "[A-Z]"` ]]; then
    echo -e "\n[ Error ] Use only lowercase characters for GITLAB_REPO.\n"
    exit 1
  fi

  if [[ ! -z `echo "${GITLAB_TRY_ACCESS}" | grep "401 Unauthorized"` ]]; then
    echo -e "\n[ Error ] Cannot access ${GITLAB_API_URL}.\n"
    exit 1
  fi

  if [[ ! -d "${GITLAB_WORK_DIR}" ]]; then
    echo -e "\n[ Error ] Gitlab work directory not found (${GITLAB_WORK_DIR}).\n"
    exit 1
  fi

  if [[ ! -z `echo "${GITLAB_AVAILABLE_PROJECTS}" | grep "^https://gitlab.local/${GITLAB_CUSTOMER_GROUP}/${GITLAB_REPO}.git$"` ]]; then
    echo -e "\n[ Error ] Project 'https://gitlab.local/${GITLAB_CUSTOMER_GROUP}/${GITLAB_REPO}.git' already exists on Gitlab.\n"
    exit 1
  fi

  COUNTER=1
  while [[ "${COUNTER}" -le "${GITLAB_AVAILABLE_PROJECTS_PAGES}" ]]; do
    for GITLAB_REPO_ID in `curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?page=${COUNTER}" | python -m json.tool  | grep "http_url_to_repo|\"id\"" | sed "s|            .*||g" | grep "\"id\"" | grep -o -E '[0-9]+'` ; do
      GITLAB_REPO_NAME=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
      if [[ ! -z `echo "${GITLAB_REPO_NAME}" | grep "^https://gitlab.local/${GITLAB_CUSTOMER_GROUP}/${GITLAB_REPO}.git$"` ]]; then
        echo -e "\n[ Error ] Project 'https://gitlab.local/${GITLAB_CUSTOMER_GROUP}/${GITLAB_REPO}.git' already exists on Gitlab.\n"
        exit 1
      fi
    done
    (( COUNTER++ ))
  done

fi

##########################
### Jenkins Conditions ###
##########################

if [[ "${JENKINS_INSTALL}" == "Yes" ]]; then

 if [[ -z "${JENKINS_JOB_NAME}" ]] || [[ -z "${JENKINS_JOB_VIEW}" ]] || [[ -z "${JENKINS_JOB_REPO}" ]] || [[ -z "${JENKINS_JOB_CUSTOMER}" ]] || [[ -z "${JENKINS_JOB_TYPE}" ]] || [[ -z "${JENKINS_JOB_CONTACT}" ]] || [[ -z "${JENKINS_JOB_NOTES}" ]]; then
    echo -e "\n[ Error ]  Jenkins parameters can not be blank.\n"
    exit 1
  fi

 if [[ "${JENKINS_JOB_NAME}" == "(empty)" ]] || [[ "${JENKINS_JOB_VIEW}" == "(empty)" ]] || [[ "${JENKINS_JOB_REPO}" == "(empty)" ]] || [[ "${JENKINS_JOB_CUSTOMER}" == "(empty)" ]] || [[ "${JENKINS_JOB_TYPE}" == "(empty)" ]] || [[ "${JENKINS_JOB_CONTACT}" == "(empty)" ]] || [[ "${JENKINS_JOB_NOTES}" == "(empty)" ]]; then
    echo -e "\n[ Error ]  Jenkins parameters can not be empty.\n"
    exit 1
  fi

  if [[ "${JENKINS_JOB_NAME}" =~ [^a-z0-9-_] ]]; then
    echo -e "\n[ Error ] Special characters are not allowed for JENKINS_JOB_NAME.\n"
    exit 1
  fi

  if [[ ! -z `echo "${JENKINS_JOB_VIEW}" | egrep -v '^[[:upper:]]+$'` ]]; then
    echo -e "\n[ Error ] Use only characters in uppercase for JENKINS_JOB_VIEW.\n"
    exit 1
  fi

  if [[ ! -d "${JENKINS_WORK_DIR}" ]]; then
    echo -e "\n[ Error ] Jenkins work directory not found (${JENKINS_WORK_DIR}).\n"
    exit 1
  fi

  curl --output /dev/null --silent --insecure --fail --user "${JENKINS_TOKEN}" -XGET "${JENKINS_URL}/job/${JENKINS_JOB_NAME}"
  if [[ $? -eq 0 ]]; then
    echo -e "\n[ Error ] Project '${JENKINS_PROJECT_URL}' already exists on Jenkins.\n"
    exit 1
  fi

fi

#######################
### Jira Conditions ###
#######################

if [[ "${JIRA_INSTALL}" == "Yes" ]]; then

  if [[ -z "${JIRA_KEY}" ]] || [[ -z "${JIRA_TEMPLATE}" ]] || [[ -z "${JIRA_CUSTOMER_ALIAS}" ]] || [[ -z "${JIRA_CUSTOMER_MANAGER_NAME}" ]] || [[ -z "${JIRA_PROJECT_MANAGER}" ]] || [[ -z "${JIRA_PROJECT}" ]] || [[ -z "${JIRA_ISSUE_SCHEMA}" ]] || [[ -z "${JIRA_WORKFLOW_SCHEMA}" ]]; then
    echo -e "\n[ Error ]  Jira parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${JIRA_KEY}" == "(empty)" ]] || [[ "${JIRA_TEMPLATE}" == "(empty)" ]] || [[ "${JIRA_CUSTOMER_ALIAS}" == "(empty)" ]] || [[ "${JIRA_CUSTOMER_MANAGER_NAME}" == "(empty)" ]] || [[ "${JIRA_PROJECT_MANAGER}" == "(empty)" ]] || [[ "${JIRA_PROJECT}" == "(empty)" ]] || [[ "${JIRA_ISSUE_SCHEMA}" == "(empty)" ]] || [[ "${JIRA_WORKFLOW_SCHEMA}" == "(empty)" ]]; then
    echo -e "\n[ Error ]  Jira parameters can not be empty.\n"
    exit 1
  fi

  if [[ ! -z `echo "${JIRA_KEY}" | egrep -v '^[[:upper:]]+$'` ]]; then
    echo -e "\n[ Error ] Use only characters in uppercase for JIRA_KEY.\n"
    exit 1
  fi

  if [[ "${JIRA_KEY}" =~ [^A-Z0-9] ]]; then
    echo -e "[ Error ] Special characters are not allowed on JIRA_KEY."
    exit 1
  fi

  if [[ `echo "${JIRA_KEY}" | wc -c` -gt "8" ]]; then
    echo -e "[ Error ] Are allowed a maximum of 7 characters on JIRA_KEY."
    exit 1
  fi

  if [[ ! -z `"${JIRACLI_DIR}/${JIRACLI_BIN}" --action getProjectList | awk -F "," '{print $1}' | egrep ^\" | egrep -v \"Key\" | sed "s|\"||g" | egrep "^${JIRA_KEY}$"` ]]; then
    echo -e "[ Error ] JIRA_KEY already exists."
    exit 1
  fi

  if [[ -z `echo "${JIRA_PROJECT_MANAGER}" | egrep ^vnt` ]]; then
    echo -e "[ Error ] JIRA_PROJECT_MANAGER must be a vnt username."
    exit 1
  fi

  JIRA_PROJECT_MANAGER_VALIDATION=`"${JIRACLI_DIR}/${JIRACLI_BIN}" --action getUserList --group "Acesso_Gerentes_Projeto" | awk -F "\"" '{print $2}' | egrep -v ^$ | egrep -v User | sort -u | egrep "^${JIRA_PROJECT_MANAGER}$"`

  #if [[ -z "${JIRA_PROJECT_MANAGER_VALIDATION}" ]]; then
  #  echo -e "[ Error ] JIRA_PROJECT_MANAGER not in AD group 'Acesso_Gerentes_Projeto'."
  #  exit 1
  #fi

  if [[ "${JIRA_PROJECT}" =~ [^a-z0-9-_] ]]; then
    echo -e "\n[ Error ] Special characters are not allowed for JIRA_PROJECT.\n"
    exit 1
  fi

  if [[ ! -f "${JIRACLI_DIR}/${JIRACLI_BIN}" ]]; then
    echo -e "[ Error ] jira-cli (command line interface) not found."
    exit 1
  fi

fi

##########################
### Rancher Conditions ###
##########################

if [[ "${RANCHER_INSTALL}" == "Yes" ]]; then

  if [[ -z "${RANCHER_PROJECT}" ]] || [[ -z "${RANCHER_USER}" ]] || [[ -z "${RANCHER_TOKEN}" ]]; then
    echo -e "\n[ Error ]  Rancher parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${RANCHER_PROJECT}" == "(empty)" ]] || [[ "${RANCHER_NAMESPACE}" == "(empty)" ]] || [[ "${RANCHER_REGISTRY_HOSTED}" == "(empty)" ]] || [[ "${RANCHER_REGISTRY_GROUP}" == "(empty)" ]]; then
    echo -e "\n[ Error ]  Rancher parameters can not be empty.\n"
    exit 1
  fi

  if [[ "${RANCHER_PROJECT}" =~ [^a-z0-9-] ]]; then
    echo -e "\n[ Error ] Special characters are not allowed for RANCHER_PROJECT.\n"
    exit 1
  fi

  if [[ ! -z `echo "${RANCHER_AVAILABLE_PROJECTS}" | grep "${RANCHER_PROJECT}"` ]]; then
    echo -e "\n[ Error ] Project '${RANCHER_PROJECT}' already exists on Rancher.\n"
    exit 1
  fi

  if [[ ! -f "${HOME}/.kube/config" ]]; then
    /srv/config/tools/rancher/kubectl config set-credentials "${RANCHER_USER}" --token "${RANCHER_TOKEN}" >/dev/null 2>/dev/null
    /srv/config/tools/rancher/kubectl config set-cluster "${RANCHER_CLUSTER}" --insecure-skip-tls-verify="true" --server="${RANCHER_SERVER}" >/dev/null 2>/dev/null
    /srv/config/tools/rancher/kubectl config set-context "${RANCHER_PROJECT}" --user="${RANCHER_USER}" --cluster="${RANCHER_CLUSTER}" >/dev/null 2>/dev/null
    /srv/config/tools/rancher/kubectl config use-context "${RANCHER_PROJECT}" >/dev/null 2>/dev/null
  fi

  if [[ ! -z `echo "${RANCHER_AVAILABLE_NAMESPACES}" | grep "^${RANCHER_PROJECT}-${RANCHER_NAMESPACE1}$"` ]]; then
    echo -e "\n[ Error ] Namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE1}' already exists on Rancher.\n"
    exit 1
  fi

  if [[ ! -z `echo "${RANCHER_AVAILABLE_NAMESPACES}" | grep "^${RANCHER_PROJECT}-${RANCHER_NAMESPACE2}$"` ]]; then
    echo -e "\n[ Error ] Namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE2}' already exists on Rancher.\n"
    exit 1
  fi

  if [[ ! -z `echo "${RANCHER_AVAILABLE_NAMESPACES}" | grep "^${RANCHER_PROJECT}-${RANCHER_NAMESPACE3}$"` ]]; then
    echo -e "\n[ Error ] Namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE3}' already exists on Rancher.\n"
    exit 1
  fi

fi

########################
### Sonar Conditions ###
########################

if [[ "${SONAR_INSTALL}" == "Yes" ]]; then

  if [[ -z "${SONAR_KEY}" ]] || [[ -z "${SONAR_CUSTOMER}" ]] || [[ -z "${SONAR_PROJECT}" ]]; then
    echo -e "\n[ Error ]  SonarQube parameters can not be blank.\n"
    exit 1
  fi

  if [[ "${SONAR_KEY}" == "(empty)" ]] || [[ "${SONAR_CUSTOMER}" == "(empty)" ]] || [[ "${SONAR_PROJECT}" == "(empty)" ]]; then
    echo -e "\n[ Error ]  SonarQube parameters can not be empty.\n"
    exit 1
  fi

  if [[ ! -z `echo "${SONAR_KEY}" | egrep -v '^[[:upper:]]+$'` ]]; then
    echo -e "\n[ Error ] Use only characters in uppercase for SONAR_KEY.\n"
    exit 1
  fi

  if [[ ! -z `curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X GET "${SONAR_API_URL}/projects/search" | python -m json.tool | grep "\"key\": \"${SONAR_KEY}\""` ]]; then
    echo -e "\n[ Error ] SONAR_KEY already exists.\n"
    exit 1
  fi

fi

######################
### Docker Install ###
######################

echo ""
echo "------------------------"
echo " Rundeck: Create Docker "
echo "------------------------"

if [[ "${DOCKER_INSTALL}" == "Yes" ]]; then

  # Creating blobstore
  echo -e "\n* Creating blobstore '${CUSTOMER}'\n"
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: application/json' ${DOCKER_API_URL} -d @${DOCKER_JSON_DIR}/blobstore.json >/dev/null 2>/dev/null
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X PUT --header 'Content-Type: application/json' ${DOCKER_API_URL}/blobstore -d @${DOCKER_JSON_DIR}/blobstore.json
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: text/plain' ${DOCKER_API_URL}/blobstore/run -d "{ \"blobname\": \"${CUSTOMER}\" }"
  echo ""
  # Creating docker-hosted repository
  echo -e "\n* Creating docker hosted repository 'docker-${CUSTOMER}-hosted (${DOCKER_HOSTED_PORT})'\n"
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: application/json' ${DOCKER_API_URL} -d @${DOCKER_JSON_DIR}/docker-hosted.json >/dev/null 2>/dev/null
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X PUT --header 'Content-Type: application/json' ${DOCKER_API_URL}/docker-hosted -d @${DOCKER_JSON_DIR}/docker-hosted.json
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: text/plain' ${DOCKER_API_URL}/docker-hosted/run -d "{ \"reponame\":\"docker-${CUSTOMER}-hosted\",\"repoport\":\"${DOCKER_HOSTED_PORT}\",\"repoblob\":\"${CUSTOMER}\" }"
  echo ""
  # Creating docker-group repository
  echo -e "\n* Creating docker group repository 'docker-${CUSTOMER}-group (${DOCKER_GROUP_PORT})'\n"
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: application/json' ${DOCKER_API_URL} -d @${DOCKER_JSON_DIR}/docker-group.json >/dev/null 2>/dev/null
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X PUT --header 'Content-Type: application/json' ${DOCKER_API_URL}/docker-group -d @${DOCKER_JSON_DIR}/docker-group.json
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: text/plain' ${DOCKER_API_URL}/docker-group/run -d "{ \"reponame\":\"docker-${CUSTOMER}-group\",\"repoport\":\"${DOCKER_GROUP_PORT}\",\"repoblob\":\"${CUSTOMER}\",\"repohosted\":\"docker-${CUSTOMER}-hosted\" }"
  echo ""
  # Creating role
  echo -e "\n* Creating role '${DOCKER_AD_GROUP}'\n"
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: application/json' ${DOCKER_API_URL} -d @${DOCKER_JSON_DIR}/role.json >/dev/null 2>/dev/null
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X PUT --header 'Content-Type: application/json' ${DOCKER_API_URL}/role -d @${DOCKER_JSON_DIR}/role.json
  curl --silent --insecure --user ${DOCKER_USER}:${DOCKER_PASS} -X POST --header 'Content-Type: text/plain' ${DOCKER_API_URL}/role/run -d "{ \"roleadgroup\":\"${DOCKER_AD_GROUP}\",\"rolecustomer\":\"${CUSTOMER}\" }"

fi

######################
### Gitlab Install ###
######################

echo ""
echo "------------------------"
echo " Rundeck: Create Gitlab "
echo "------------------------"

if [[ "${GITLAB_INSTALL}" == "Yes" ]]; then

  # Checking if customer group already exists
  if [[ -z `echo "${GITLAB_AVAILABLE_GROUPS}" | grep "^${GITLAB_CUSTOMER_GROUP}$"` ]]; then
    # Creating customer group
    echo -e "\n* Creating customer group '${GITLAB_CUSTOMER_GROUP}'\n"
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups?full_name=${GITLAB_CUSTOMER_GROUP}&full_path=${GITLAB_CUSTOMER_GROUP}&lfs_enabled=true&name=${GITLAB_CUSTOMER_GROUP}&path=${GITLAB_CUSTOMER_GROUP}&request_access_enabled=false&visibility_level=0&web_url=https://gitlab.local/groups/${GITLAB_CUSTOMER_GROUP}"
    if [[ $? -ne 0 ]]; then
      echo -e "\n[ Error ] An error occurred while creating customer group '${GITLAB_CUSTOMER_GROUP}'.\n"
      exit 1
    fi
    GITLAB_CUSTOMER_GROUP_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?search=${GITLAB_CUSTOMER_GROUP}" | python -m json.tool | grep -oP "full_path.*${GITLAB_CUSTOMER_GROUP}\"|id.*" | grep -A1 "${GITLAB_CUSTOMER_GROUP}" | grep "id" | grep -o -E '[0-9]+'`
    echo ""
    # Creating service account
    echo -e "\n* Creating service account '${GITLAB_CUSTOMER_GROUP}'\n"
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/users?username=${GITLAB_CUSTOMER_GROUP}&name=${GITLAB_CUSTOMER_GROUP}%20%28service%20user%29&email=${GITLAB_CUSTOMER_GROUP}@local&password=<pass><pass>&skip_confirmation=true" | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+' 2>/dev/null
    GITLAB_USER_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?search=${GITLAB_CUSTOMER_GROUP} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups/${GITLAB_CUSTOMER_GROUP_ID}/members?user_id=${GITLAB_USER_ID}&access_level=20" | python -m json.tool
  else
    # Skipping customer group creation
    echo -e "\n* Creating customer group '${GITLAB_CUSTOMER_GROUP}'\n"
    echo -e "Customer group '${GITLAB_CUSTOMER_GROUP}' already exists. Skiping."
  fi
  # Creating project group
  # Checking if project group already exists
  if [[ -z `echo "${GITLAB_AVAILABLE_GROUPS}" | grep "^${GITLAB_PROJECT_GROUP}$"` ]]; then
    echo -e "\n* Creating project group '${GITLAB_PROJECT_GROUP}'\n"
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups?full_name=${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}&full_path=${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}&parent_id=${GITLAB_CUSTOMER_GROUP_ID}&lfs_enabled=true&name=${GITLAB_PROJECT_GROUP}&path=${GITLAB_PROJECT_GROUP}&request_access_enabled=false&visibility_level=0&web_url=https://gitlab.local/groups/${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}"
    if [[ $? -ne 0 ]]; then
      echo -e "\n[ Error ] An error occurred while creating customer group '${GITLAB_PROJECT_GROUP}'.\n"
      exit 1
    fi
  else
    # Skipping project group creation
    echo -e "\n* Creating project group '${GITLAB_PROJECT_GROUP}'\n"
    echo -e "Project group '${GITLAB_PROJECT_GROUP}' already exists. Skiping."
  fi
  echo ""
  # Creating project
  GITLAB_CUSTOMER_GROUP_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?search=${GITLAB_CUSTOMER_GROUP}" | python -m json.tool | grep -oP "full_path.*${GITLAB_CUSTOMER_GROUP}\"|id.*" | grep -A1 "${GITLAB_CUSTOMER_GROUP}" | grep "id" | grep -o -E '[0-9]+' | head -n 1`
  GITLAB_PROJECT_GROUP_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?search=${GITLAB_PROJECT_GROUP}" | python -m json.tool | grep -oP "full_path.*${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}\"|id.*" | grep -A1 "${GITLAB_PROJECT_GROUP}" | grep "id" | grep -o -E '[0-9]+' | head -n 1`
  echo -e "\n* Creating project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}' (project group id: ${GITLAB_PROJECT_GROUP_ID})\n"
  sleep 1
  if [[ "${JENKINS_INSTALL}" == "Yes" ]]; then
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects?name=${GITLAB_REPO}&namespace_id=${GITLAB_PROJECT_GROUP_ID}&default_branch=master&jobs_enabled=true&only_allow_merge_if_pipeline_succeeds=true"
  else
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects?name=${GITLAB_REPO}&namespace_id=${GITLAB_PROJECT_GROUP_ID}&default_branch=master&jobs_enabled=true&only_allow_merge_if_pipeline_succeeds=false"
  fi
  if [[ $? -ne 0 ]]; then
    echo -e "\n[ Error ] An error occurred while creating project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}'.\n"
    exit 1
  fi
  echo ""
  GITLAB_REPO_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_CUSTOMER_GROUP}%2F${GITLAB_PROJECT_GROUP}%2F${GITLAB_REPO}" | python -m json.tool | grep "\"id\"" | head -n 1 | sed "s|[^0-9]*||g"`
  if [[ -z "${GITLAB_REPO_ID}" ]]; then
    echo -e "[ Error ] Cannot get GITLAB_REPO_ID."
    exit 1
  fi
  # Creating branch development
  echo -e "\n* Creating branch development\n"
  curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches?branch=development&ref=master" | python -m json.tool
  sleep 2
  # Change default branch to development
  echo -e "\n* Changing default branch to development\n"
  curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}?default_branch=development" | python -m json.tool
  sleep 2
  # Creating branch qa
  echo -e "\n* Creating branch qa\n"
  curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches?branch=qa&ref=master" | python -m json.tool
  sleep 2
  # Creating branch main
  echo -e "\n* Creating branch main\n"
  curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches?branch=main&ref=master" | python -m json.tool
  sleep 2
  # Granting permissions
  GITLAB_CUSTOMER_AD_GROUPS=`cat "${AD_GROUPS_FILE}" | grep "^${CUSTOMER}.*" | awk '{print $NF}' | sed "s|,|\n|g" | sed "s|@||g" | sed "s|=.*||g"`
  echo -e "\n* Granting permission to customer AD groups:\n\n${GITLAB_CUSTOMER_AD_GROUPS}\n"
  for GROUP in `echo -e "${GITLAB_CUSTOMER_AD_GROUPS}"` ; do
    GROUP_EXIST=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/groups?search="${GROUP}" | python -m json.tool | grep "full_path" | awk -F ":" '{print $2}' | awk -F "\"" '{print $2}' | grep "^${GROUP}$"`
    if [ -z "${GROUP_EXIST}" ] ; then
      GITLAB_CUSTOMER_AD_GROUP_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups?full_name=${GROUP}&full_path=${GROUP}&lfs_enabled=true&name=${GROUP}&path=${GROUP}&request_access_enabled=false&visibility=private&web_url=https://gitlab.local/groups/${GROUP}" | python -m json.tool | grep "\"id\":" | grep -o -E '[0-9]+'`
      GITLAB_CUSTOMER_AD_GROUP_USERS=`cat "${AD_GROUPS_USERS_FILE}" | grep "^${GROUP} = " | awk -F "=" '{print $2}' | sed "s| ||g" | sed "s|,|\n|g"`
      for USER in `echo -e "${GITLAB_CUSTOMER_AD_GROUP_USERS}"` ; do
        GITLAB_USER_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/users?search=${USER} | python -m json.tool | grep "\"id\"" | grep -o -E '[0-9]+'`
        if [[ -z "${GITLAB_USER_ID}" ]]; then
          LDAP_QUERY=`ldapsearch -x -h "<host>" -D "<binddn>" -w "<bindpass>" -b "<basedn>" "sAMAccountName=${USER}" | grep -e ^cn -e ^sAMAccountName -e ^mail: | perl -MMIME::Base64 -MEncode=decode -n -00 -e 's/\n +//g;s/(?<=:: )(\S+)/decode("ISO-8859-1",decode_base64($1))/eg;print'`
          GITLAB_USER_ACCOUNT="${USER}"
          GITLAB_USER_NAME=`echo "${LDAP_QUERY}" | grep ^cn | sed "s|cn: ||g" | sed "s| |%20|g"`
          GITLAB_USER_EMAIL=`echo "${LDAP_QUERY}" | grep ^mail | sed "s|mail: ||g"`
          if [ -z "${GITLAB_USER_EMAIL}" ]; then
            GITLAB_USER_EMAIL="${GITLAB_USER_ACCOUNT}@local"
          fi
          curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/users?username=${GITLAB_USER_ACCOUNT}&name=${GITLAB_USER_NAME}&email=${GITLAB_USER_EMAIL}&password=venturus&skip_confirmation=true" | python -m json.tool
          sleep 3
        fi
        curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/groups/${GITLAB_CUSTOMER_AD_GROUP_ID}/members?user_id=${GITLAB_USER_ID}&access_level=30" | python -m json.tool
      done
    fi
  done
  for GROUP in `echo -e "${GITLAB_CUSTOMER_AD_GROUPS}"` ; do
    GITLAB_CUSTOMER_AD_GROUP_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups?search=${GROUP}" | python -m json.tool | grep -oP "full_path.*${GROUP}\"|id.*" | grep -A1 "${GROUP}" | grep "id" | grep -o -E '[0-9]+'`
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/share?group_id=${GITLAB_CUSTOMER_AD_GROUP_ID}&group_access=30"
  done
  echo ""
  # Adding template
  if [[ "${GITLAB_TEMPLATE}" != "(empty)" ]]; then
    echo -e "\n* Adding '${GITLAB_TEMPLATE}' code template\n"
    cd "${GITLAB_WORK_DIR}"
    rm -rf "${GITLAB_TEMPLATE_DIR}" 2>/dev/null
    git clone ${GITLAB_TEMPLATE}
    if [[ -d "${GITLAB_TEMPLATE_DIR}" ]]; then
      cd "${GITLAB_TEMPLATE_DIR}"
      rm -rf .git
      grep -r "<project_customer>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<project_customer>|${CUSTOMER}|g"
      grep -r "<project_group>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<project_group>|${GITLAB_PROJECT_GROUP}|g"
      grep -r "<project_name>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<project_name>|${GITLAB_REPO}|g"
      grep -r "<build_name>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<build_name>|${GITLAB_REPO}|g"
      grep -r "<build_version>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<build_version>|1.0|g"

      if [[ ! -z "${RANCHER_USER}" ]] && [[ "${RANCHER_USER}" != "(empty)" ]] && [[ -f Jenkinsfile ]]; then
        sed -i "s|<rancher_user>|${RANCHER_USER}|g" Jenkinsfile
      fi

      if [[ ! -z "${RANCHER_TOKEN}" ]] && [[ "${RANCHER_TOKEN}" != "(empty)" ]] && [[ -f Jenkinsfile ]]; then
        sed -i "s|<rancher_token>|${RANCHER_TOKEN}|g" Jenkinsfile
      fi

      if [[ ! -z "${SONAR_CUSTOMER}" ]] && [[ "${SONAR_CUSTOMER}" != "(empty)" ]] && [[ -f sonar-project.properties ]]; then
        sed -i "s|${CUSTOMER}|${SONAR_CUSTOMER}|g" sonar-project.properties
      fi
      if [[ ! -z "${SONAR_PROJECT}" ]] && [[ "${SONAR_PROJECT}" != "(empty)" ]] && [[ -f sonar-project.properties ]]; then
        sed -i "s|${GITLAB_REPO}|${SONAR_PROJECT}|g" sonar-project.properties
      fi
      # Creating credentials in Jenkins
      if [[ -z `curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET "${JENKINS_URL}/credentials/store/system/domain/_/" | grep ">${CUSTOMER}/"` ]]; then
        echo -e "* Creating credentials in Jenkins\n"
        curl --silent --insecure --user "${JENKINS_TOKEN}" -X POST "${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" --data-urlencode "json={  
  '': '0',
  'credentials': {
    'scope': 'GLOBAL',
    'id': '',
    'username': '${CUSTOMER}',
    'password': '<pass>',
    'description': 'Gitlab Service User (Jenkins Pipeline)',
    'stapler-class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
  }
}"
      fi
      GIT_CREDENTIALS=`curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET "${JENKINS_URL}/credentials/store/system/domain/_/" | grep "${CUSTOMER}" | sed "s|${CUSTOMER}.*||g" | sed "s|.*credential/||g" | sed "s|\".*||g"`
      if [[ ! -z "${GIT_CREDENTIALS}" ]] && [[ "${GIT_CREDENTIALS}" != "(empty)" ]]; then
        grep -r "<git_credentials>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<git_credentials>|${GIT_CREDENTIALS}|g"
      fi
      if [[ ! -z "${JIRA_KEY}" ]] && [[ "${JIRA_KEY}" != "(empty)" ]]; then
        grep -r "<jira_key>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<jira_key>|${JIRA_KEY}|g"
      fi
      if [[ ! -z "${SONAR_KEY}" ]] && [[ "${SONAR_KEY}" != "(empty)" ]]; then
        grep -r "<sonar_project_key>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<sonar_project_key>|${SONAR_KEY}|g"
        grep -r "<sonar_min_coverage>" | awk -F ":" '{print $1}' | sort -u | xargs sed -i "s|<sonar_min_coverage>|30|g"
      fi
      git init
      git config --global user.name "${GITLAB_INTEGRATION_USER}"
      git config --global user.email "${GITLAB_INTEGRATION_EMAIL}" 
      git remote add origin git@gitlab:${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}.git
      git checkout -b development
      git add .
      git commit -m "[DEVOPS] Initial commit"
      git push -u --force origin development
      cd "${GITLAB_WORK_DIR}"
      rm -rf "${GITLAB_TEMPLATE_DIR}" 2>/dev/null
    else
      echo -e "\n[ Warning ] Gitlab template directory not found (${GITLAB_TEMPLATE_DIR}). Skipping.\n"
    fi
  else
    echo -e "\n[ Info ] A code template was not selected. Skipping."
    #echo -e "\n* Creating branch master"
    #curl --silent --insecure --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches?branch=master&ref=master" >/dev/null
    #sleep 2
  fi
  # Protecting branch master
  #echo -e "\n* Protecting branch master on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'\n"
  #curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/master/protect"
  #curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/master/protect?developers_can_push=false&developers_can_merge=true"
  #echo ""
  # Protecting branch main
  echo -e "\n* Protecting branch main on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'\n"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/main/protect"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/main/protect?developers_can_push=false&developers_can_merge=true"
  echo ""
  # Protecting branch qa
  echo -e "\n* Protecting branch qa on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'\n"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/qa/protect"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true"
  echo ""
  # Protecting branch development
  echo -e "\n* Protecting branch development on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'\n"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/development/protect"
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true"
  # Unprotecting branch master
  echo -e "\n\n* Unprotecting branch master on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'"
  curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/protected_branches/master"
  # Delete branch master
  echo -e "* Delete branch master on project '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO} (id: ${GITLAB_REPO_ID})'"
  curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/branches/master"
  sleep 2
  # Copying custom hooks
  echo -e "\n* Copying custom hooks for '${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}'"
  GITLAB_REPO_HASHED_DIR=`ssh root@gitlab01 "cd /var/opt/gitlab/git-data/repositories/@hashed ; grep -r 'fullpath = ${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}'" | awk -F ":" '{print $1}' | sed "s|^|/var/opt/gitlab/git-data/repositories/@hashed/|g" | sed "s|/config||g"`
  echo "GITLAB_REPO_HASHED_DIR: ${GITLAB_REPO_HASHED_DIR}"
  ssh root@gitlab01 cp -pr ${GITLAB_HOOKS_TEMPLATE_DIR} ${GITLAB_REPO_HASHED_DIR} 2>/dev/null >/dev/null
  ssh root@gitlab01 chown -R git:git ${GITLAB_REPO_HASHED_DIR}/custom_hooks 2>/dev/null >/dev/null
  # Enabling Jira integration
  if [[ "${JIRA_INSTALL}" == "Yes" ]]; then
    echo -e "* Enabling Jira integration\n"
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/services/jira?url=http://jira.local:8080&username=${GITLAB_INTEGRATION_USER}&password=${GITLAB_INTEGRATION_PASS}" | python -m json.tool
    ssh root@gitlab01 sed -i "s/JIRA=0/JIRA=1/g" ${GITLAB_REPO_HASHED_DIR}/custom_hooks/pre-receive
    ssh root@gitlab01 sed -i "s/PRJ/${JIRA_KEY}/g" ${GITLAB_REPO_HASHED_DIR}/custom_hooks/pre-receive
  else
    if [[ ! -z "${JIRA_KEY}" ]] && [[ "${JIRA_KEY}" != "(empty)" ]]; then
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/services/jira?url=https://jira.local&username=${GITLAB_INTEGRATION_USER}&password=${GITLAB_INTEGRATION_PASS}" | python -m json.tool
      ssh root@gitlab01 sed -i "s/JIRA=0/JIRA=1/g" ${GITLAB_REPO_HASHED_DIR}/custom_hooks/pre-receive
      ssh root@gitlab01 sed -i "s/PRJ/${JIRA_KEY}/g" ${GITLAB_REPO_HASHED_DIR}/custom_hooks/pre-receive
    fi
  fi
  # Registering in TPP
  if [ "${TPP}" == "Yes" ]; then
    echo -e "* Registering '${GITLAB_PROJECT_URL}' in TPP\n"
    curl --silent --insecure -X POST -F "conta=${TPP_CUSTOMER}" -F "projeto=${TPP_PROJECT}" -F "id_status=1" -F "id_ferramenta=GL" -F "link=${GITLAB_PROJECT_URL}" -F "tableconta=demo" ${TPP_ADD_URL}
    echo ""
  fi
else
  echo ""
  echo "* Skipping Gitlab"
fi

#######################
### Jenkins Install ###
#######################

echo ""
echo "-------------------------"
echo " Rundeck: Create Jenkins "
echo "-------------------------"

if [[ "${JENKINS_INSTALL}" == "Yes" ]]; then
  # Getting and seding config.xml
  echo -e "\n* Creating Jenkins pipeline\n"
  JENKINS_CUSTOMER_GROUPS=`cat "${AD_GROUPS_FILE}" | grep "^${CUSTOMER}.*" | awk '{print $NF}' | sed "s|,|\n|g" | sed "s|@||g" | sed "s|=.*||g"`
  cd "${JENKINS_WORK_DIR}"
  curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET ${JENKINS_URL}/job/${JENKINS_TEMPLATE}/config.xml --output ${JENKINS_TEMPLATE}.xml
  sed -i "s|JENKINS_JOB_CUSTOMER|${JENKINS_JOB_CUSTOMER}|g" ${JENKINS_TEMPLATE}.xml
  sed -i "s|JENKINS_JOB_TYPE|${JENKINS_JOB_TYPE}|g" ${JENKINS_TEMPLATE}.xml
  sed -i "s|JENKINS_JOB_REPO|${JENKINS_JOB_REPO}|g" ${JENKINS_TEMPLATE}.xml
  sed -i "s|JENKINS_JOB_CONTACT|${JENKINS_JOB_CONTACT}|g" ${JENKINS_TEMPLATE}.xml
  sed -i "s|JENKINS_JOB_NOTES|${JENKINS_JOB_NOTES}|g" ${JENKINS_TEMPLATE}.xml
  for GROUP in `echo -e "${JENKINS_CUSTOMER_GROUPS}"` ; do
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.scm.SCM.Tag:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.plugins.promoted_builds.Promotion.Promote:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Run.Update:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Run.Replay:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Workspace:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Release:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Read:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Discover:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Cancel:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
    sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <permission>hudson.model.Item.Build:${GROUP}</permission>" ${JENKINS_TEMPLATE}.xml
  done
  sed -i "/TEMPLATE/d" ${JENKINS_TEMPLATE}.xml
  sed -i "/<inheritanceStrategy.*/d" ${JENKINS_TEMPLATE}.xml
  sed -i "/<hudson.security.AuthorizationMatrixProperty>/a\      <inheritanceStrategy class=\"org.jenkinsci.plugins.matrixauth.inheritance.InheritParentStrategy\"/>" ${JENKINS_TEMPLATE}.xml
  # Creating view if not exists
  JENKINS_CUSTOMER_ALIAS=`echo "${CUSTOMER}" | tr [:lower:] [:upper:]`
  curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET "${JENKINS_URL}/view/_EMPTY_/config.xml" --output "${JENKINS_WORK_DIR}/jenkins_view.xml"
  curl --silent --insecure --user "${JENKINS_TOKEN}" -X POST -d @"${JENKINS_WORK_DIR}/jenkins_view.xml" -H "Content-Type: text/xml" "${JENKINS_URL}/createView?name=${JENKINS_CUSTOMER_ALIAS}" >/dev/null 2>/dev/null
  rm "${JENKINS_WORK_DIR}/jenkins_view.xml" >/dev/null 2>/dev/null
  # Creating new job based on template
  curl --silent --insecure --user "${JENKINS_TOKEN}" -XPOST ${JENKINS_URL}/view/${JENKINS_JOB_VIEW}/createItem?name=${JENKINS_JOB_NAME} --data-binary @${JENKINS_TEMPLATE}.xml -H "Content-Type:text/xml"
  rm ${JENKINS_TEMPLATE}.xml
  # Enabling Gitlab Integration
  echo -e "* Enabling Gitlab Integration\n"
  GITLAB_CUSTOMER_GROUP="${CUSTOMER}"
  GITLAB_PROJECT_GROUP=`echo "${JENKINS_JOB_REPO}" | sed "s|.*gitlab.local/||g" | awk -F "/" '{print $2}'`
  GITLAB_REPO=`echo "${JENKINS_JOB_REPO}" | sed "s|.*gitlab.local/||g" | awk -F "/" '{print $3}'`
  GITLAB_REPO_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_CUSTOMER_GROUP}%2F${GITLAB_PROJECT_GROUP}%2F${GITLAB_REPO}" | python -m json.tool | grep "\"id\"" | head -n 1 | sed "s|[^0-9]*||g"`
  GITLAB_WEBHOOKS=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/hooks" | python -m json.tool | grep url | awk -F "\"" '{print $4}'`
  if [[ -z `echo "${GITLAB_WEBHOOKS}" | grep "${JENKINS_URL}/project/${JENKINS_JOB_NAME}"` ]]; then
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/hooks?url=${JENKINS_URL}/project/${JENKINS_JOB_NAME}&push_events=yes&merge_requests_events=yes&tag_push_events=yes&token=hudson-trigger&enable_ssl_verification=no" | python -m json.tool
  curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}?only_allow_merge_if_pipeline_succeeds=true" | python -m json.tool
  else
    echo -e "Gitlab integration already enabled. Skiping."
  fi
  # Creating credentials in Jenkins
  if [[ -z `curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET "${JENKINS_URL}/credentials/store/system/domain/_/" | grep ">${CUSTOMER}/"` ]]; then
    echo -e "\n* Creating credentials in Jenkins\n"
    curl --silent --insecure --user "${JENKINS_TOKEN}" -X POST "${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" --data-urlencode "json={  
      '': '0',
      'credentials': {
        'scope': 'GLOBAL',
        'id': '',
        'username': '${CUSTOMER}',
        'password': '<pass>',
        'description': 'Gitlab Service User (Jenkins Pipeline)',
        'stapler-class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
      }
    }"
  fi
  GIT_CREDENTIALS=`curl --silent --insecure --user "${JENKINS_TOKEN}" -X GET "${JENKINS_URL}/credentials/store/system/domain/_/" | grep "${CUSTOMER}" | sed "s|${CUSTOMER}.*||g" | sed "s|.*credential/||g" | sed "s|\".*||g"`
  # Adding Jenkinsfile and sonar-project.properties to the repository
  GITLAB_REPO_JENKINSFILE_EXIST=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/repository/files/Jenkinsfile?ref=development" | python -m json.tool | grep "404 File Not Found"`
  if [[ ! -z `echo "${GITLAB_REPO_JENKINSFILE_EXIST}"` ]]; then
    echo -e "\n* Adding Jenkinsfile to the repository"
    find /tmp -maxdepth 2 -type d -name ".git" | sed "s|/.git||g" | xargs rm -rf
    git clone git@gitlab:${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}.git
    cd ${GITLAB_REPO}
    git checkout development
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/255/repository/files/Jenkinsfile/raw?ref=main" > Jenkinsfile
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/256/repository/files/sonar-project.properties/raw?ref=main" > sonar-project.properties
    RANCHER_DOCKER_PATH="${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}"
    RANCHER_DOCKER_IMAGE="${GITLAB_REPO}"
    RANCHER_NAMESPACE="${CUSTOMER}-${GITLAB_PROJECT_GROUP}"
    sed -i "s|<project_customer>|${CUSTOMER}|g" Jenkinsfile
    sed -i "s|<project_group>|${GITLAB_PROJECT_GROUP}|g" Jenkinsfile
    sed -i "s|<project_name>|${GITLAB_PROJECT_GROUP}-${GITLAB_REPO}|g" Jenkinsfile
    sed -i "s|^env.GitURL.*|env.GitURL = \"https://gitlab.local/${CUSTOMER}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}\"|g" Jenkinsfile
    sed -i "s|<docker_path>|${RANCHER_DOCKER_PATH}|g" Jenkinsfile
    sed -i "s|<docker_image>|${RANCHER_DOCKER_IMAGE}|g" Jenkinsfile
    sed -i "s|<namespace>|${RANCHER_NAMESPACE}|g" Jenkinsfile
    if [[ ! -z "${GIT_CREDENTIALS}" ]] && [[ "${GIT_CREDENTIALS}" != "(empty)" ]]; then
      sed -i "s|<git_credentials>|${GIT_CREDENTIALS}|g" Jenkinsfile
    fi
    if [[ ! -z "${JIRA_KEY}" ]] && [[ "${JIRA_KEY}" != "(empty)" ]]; then
      sed -i "s|<jira_key>|${JIRA_KEY}|g" Jenkinsfile 
    else
      GITLAB_REPO_HASHED_DIR=`ssh root@gitlab01 "cd /var/opt/gitlab/git-data/repositories/@hashed ; grep -r 'fullpath = ${GITLAB_CUSTOMER_GROUP}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}'" | awk -F ":" '{print $1}' | sed "s|^|/var/opt/gitlab/git-data/repositories/@hashed/|g" | sed "s|/config||g"`
      JIRA_KEY=`ssh root@gitlab01 cat ${GITLAB_REPO_HASHED_DIR}/custom_hooks/pre-receive | grep '^jirakey=' | awk -F "\"" '{print $2}'`
      sed -i "s|<jira_key>|${JIRA_KEY}|g" Jenkinsfile 
    fi
    if [[ ! -z "${RANCHER_USER}" ]] && [[ "${RANCHER_USER}" != "(empty)" ]]; then
      sed -i "s|<rancher_user>|${RANCHER_USER}|g" Jenkinsfile
    fi
    if [[ ! -z "${RANCHER_TOKEN}" ]] && [[ "${RANCHER_TOKEN}" != "(empty)" ]]; then
      sed -i "s|<rancher_token>|${RANCHER_TOKEN}|g" Jenkinsfile
    fi
    if [[ ! -z "${SONAR_KEY}" ]] && [[ "${SONAR_KEY}" != "(empty)" ]]; then
      sed -i "s|<sonar_project_key>|${SONAR_KEY}|g" Jenkinsfile
      sed -i "s|<sonar_min_coverage>|30|g" Jenkinsfile
      sed -i "s|<sonar_project_key>|${SONAR_KEY}|g" sonar-project.properties
    fi
    if [[ ! -z "${SONAR_CUSTOMER}" ]] && [[ "${SONAR_CUSTOMER}" != "(empty)" ]]; then
      sed -i "s|<project_customer>|${SONAR_CUSTOMER}|g" sonar-project.properties
    fi
    if [[ ! -z "${SONAR_PROJECT}" ]] && [[ "${SONAR_PROJECT}" != "(empty)" ]]; then
      sed -i "s|<project_name>|${SONAR_PROJECT}|g" sonar-project.properties
    fi
    git add Jenkinsfile sonar-project.properties
    git config --global push.default simple
    #git commit -m "[${JIRA_KEY}-0] Add Jenkinsfile and sonar-project.properties templates"
    git commit -m "[DEVOPS] Add Jenkinsfile and sonar-project.properties templates"
    git push origin development
  fi
  # Registering in TPP
  if [ "${TPP}" == "Yes" ]; then
    echo -e "\n* Registering '${JENKINS_PROJECT_URL}' in TPP\n"
    curl --silent --insecure -X POST -F "conta=${TPP_CUSTOMER}" -F "projeto=${TPP_PROJECT}" -F "id_status=1" -F "id_ferramenta=JE" -F "link=${JENKINS_PROJECT_URL}" -F "tableconta=demo" ${TPP_ADD_URL}
    echo ""
  fi
  # Manual steps
  echo ""
  echo "------------------------"
  echo " ATENTION: MANUAL STEPS "
  echo "------------------------"
  echo ""
  echo -e "- If this project has a Jira, manually enable integration:\n  https://jira.local/secure/admin/jji/sites/0a79709cb03041588ca879faaded3869" 
else
  echo ""
  echo "* Skipping Jenkins"
fi

####################
### Jira Install ###
####################

echo ""
echo "----------------------"
echo " Rundeck: Create Jira "
echo "----------------------"

if [[ "${JIRA_INSTALL}" == "Yes" ]]; then
  # Create new project based on template
  echo -e "\n* Cloning template '${JIRA_TEMPLATE}'\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action cloneProject --project "${JIRA_TEMPLATE}" --toProject "${JIRA_KEY}" --name "${JIRA_NAME}" --description " " --copyRoleActors --cloneIssues --copyAttachments --copySubtasks --copyLinks --copyComments --continue
  # Updating issue and workflow schemas
  echo -e "\n* Updating issue and workflow schemas"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateProject --project "${JIRA_KEY}" --lead "${JIRA_PROJECT_MANAGER}" --issueTypeScheme "${JIRA_ISSUE_SCHEMA}" --workflowScheme "${JIRA_WORKFLOW_SCHEMA}"
  # Grantting permissions
  echo -e "\n* Grantting permissions\n"
  JIRA_CUSTOMER_AD_GROUPS=`cat "${AD_GROUPS_FILE}" | grep "${CUSTOMER}.*" | awk '{print $NF}' | sed "s|,|\n|g" | sed "s|@||g" | sed "s|=.*||g"`
  JIRA_CUSTOMER_AD_GROUPS_ADMIN=`echo -e "${JIRA_CUSTOMER_AD_GROUPS}" | egrep "(_Programa|_Projeto)"`
  # Grantting permissions on role 'Administrators'
  echo -e "Role: Administrators\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action addProjectRoleActors --project "${JIRA_KEY}" --role "Administrators" --group "${JIRA_CUSTOMER_AD_GROUPS_ADMIN}"
  # Grantting permissions on role 'Developers'
  echo -e "\nRole: Developers\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action addProjectRoleActors --project "${JIRA_KEY}" --role "Developers" --group "${JIRA_CUSTOMER_AD_GROUPS}"
  # Grantting permissions on role 'Users'
  echo -e "\nRole: Users\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action addProjectRoleActors --project "${JIRA_KEY}" --role "Users" --group "${JIRA_CUSTOMER_AD_GROUPS}"
  # Creating filter and board
  echo -e "\n* Creating filter and board\n"
  JIRA_FILTER_ID=`"${JIRACLI_DIR}/${JIRACLI_BIN}" --action createBoard --project "${JIRA_KEY}" --name "${JIRA_NAME}" --type scrum | awk -F " " '{print $NF}' | sed "s|\.||g" | tail -n 1`
  JIRA_BOARD_ID=`"${JIRACLI_DIR}/${JIRACLI_BIN}" --action getBoardList --regex "${JIRA_NAME}" --columns 1 | sed "s|\"||g" | grep "^[0-9].*[0-9]$"`
  JIRA_PROJECT_ID=$(curl --silent --insecure --user ${JIRA_REST_AUTH} -X GET -H "Content-Type: application/json" ${JIRA_REST_URL}/project/${JIRA_KEY} | python -m json.tool | grep self | tail -n 1 | awk -F "/" '{print $NF}' | sed "s|\",||g")
  curl --silent --insecure --request POST --user ${JIRA_REST_AUTH} --header "Accept: application/json" --header "Content-Type: application/json" --data "{ \"type\": \"project\", \"projectId\": \"${JIRA_PROJECT_ID}\" }" --url ${JIRA_REST_URL}/filter/${JIRA_FILTER_ID}/permission
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateFilter --id "${JIRA_FILTER_ID}" --name "Filter for ${JIRA_NAME}" --description "" --favorite
  # Some commands using REST API: https://docs.atlassian.com/jira-software/REST/7.3.1
  # Creating sprints
  echo -e "\n* Creating sprints\n"
  JIRA_SPRINT01_ID=`curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{ \"name\": \"INFORMAÇÕES DO PROJETO\", \"originBoardId\": \"${JIRA_BOARD_ID}\" }" ${JIRA_REST_AGILE_URL}/sprint | python -m json.tool | grep self | awk -F "/" '{print $NF}' | sed "s|\",||g"`
  JIRA_SPRINT02_ID=`curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{ \"name\": \"RISCOS DO PROJETO\", \"originBoardId\": \"${JIRA_BOARD_ID}\" }" ${JIRA_REST_AGILE_URL}/sprint | python -m json.tool | grep self | awk -F "/" '{print $NF}' | sed "s|\",||g"`
  JIRA_SPRINT03_ID=`curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{ \"name\": \"MINUTAS E RELATÓRIOS\", \"originBoardId\": \"${JIRA_BOARD_ID}\" }" ${JIRA_REST_AGILE_URL}/sprint | python -m json.tool | grep self | awk -F "/" '{print $NF}' | sed "s|\",||g"`
  JIRA_SPRINT04_ID=`curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{ \"name\": \"MILESTONES\", \"originBoardId\": \"${JIRA_BOARD_ID}\" }" ${JIRA_REST_AGILE_URL}/sprint | python -m json.tool | grep self | awk -F "/" '{print $NF}' | sed "s|\",||g"`
  JIRA_SPRINT05_ID=`curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{ \"name\": \"CHANGE REQUESTS\", \"originBoardId\": \"${JIRA_BOARD_ID}\" }" ${JIRA_REST_AGILE_URL}/sprint | python -m json.tool | grep self | awk -F "/" '{print $NF}' | sed "s|\",||g"`
  # Adding issues into sprints
  # INFORMAÇÕES DO PROJETO
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-1\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT01_ID}/issue"
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-2\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT01_ID}/issue"
  # RISCOS DO PROJETO
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-3\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT02_ID}/issue"
  # MINUTAS E RELATÓRIOS
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-4\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT03_ID}/issue"
  # MILESTONES
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-6\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT04_ID}/issue"
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-7\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT04_ID}/issue"
  # CHANGE REQUESTS
  curl --silent --insecure --user "${JIRA_REST_AUTH}" -H "Content-Type: application/json" -X POST --data "{\"issues\":[\"${JIRA_KEY}-5\"]}" "${JIRA_REST_AGILE_URL}/sprint/${JIRA_SPRINT05_ID}/issue"
  echo -e "\n* Updating issues reporter\n"
  # Updating issues reporter
  echo -e "* Updating issues reporter\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-1" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-2" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-3" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-4" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-5" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-6" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-7" --reporter "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-8" --reporter "${JIRA_PROJECT_MANAGER}"
  # Updating assignee
  echo -e "\n* Updating issues assignee\n"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-1" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-2" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-3" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-4" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-5" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-6" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-7" --assignee "${JIRA_PROJECT_MANAGER}"
  "${JIRACLI_DIR}/${JIRACLI_BIN}" --action updateIssue --issue "${JIRA_KEY}-8" --assignee "${JIRA_PROJECT_MANAGER}"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"reporter\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-8"
  # Updating assignee
  echo -e "\n* Updating issues assignee\n"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-1"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-2"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-3"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-4"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-5"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-6"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-7"
  curl --silent --user "${JIRA_REST_AUTH}" -k -X PUT --data "{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}" -H "Content-Type: application/json" "${JIRA_REST_URL}/issue/${JIRA_KEY}-8"

 echo "curl --silent --user \"${JIRA_REST_AUTH}\" -k -X PUT --data \"{\"fields\":{\"assignee\":{\"name\":\"${JIRA_PROJECT_MANAGER}\"}}}\" -H \"Content-Type: application/json\" \"${JIRA_REST_URL}/issue/${JIRA_KEY}-8\""

  # Enabling Gitlab Integration
  if [[ ! -z "${GITLAB_PROJECT_GROUP}" ]] && [[ ! -z "${GITLAB_REPO}" ]] && [[ "${GITLAB_PROJECT_GROUP}" != "(empty)" ]] && [[ "${GITLAB_REPO}" != "(empty)" ]]; then
    echo -e "\n* Enabling Gitlab Integration\n"
    GITLAB_REPO_ID=`curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_CUSTOMER_GROUP}%2F${GITLAB_PROJECT_GROUP}%2F${GITLAB_REPO}" | python -m json.tool | grep "\"id\"" | head -n 1 | sed "s|[^0-9]*||g"`
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_REPO_ID}/services/jira?url=http://jira.local:8080&username=${GITLAB_INTEGRATION_USER}&password=${GITLAB_INTEGRATION_PASS}" | python -m json.tool
  fi
  # Registering in TPP
  if [ "${TPP}" == "Yes" ]; then
    echo -e "\n* Registering '${JIRA_PROJECT_URL}' in TPP\n"
    curl --silent --insecure -X POST -F "conta=${TPP_CUSTOMER}" -F "projeto=${TPP_PROJECT}" -F "id_status=1" -F "id_ferramenta=JI" -F "link=${JIRA_PROJECT_URL}" -F "tableconta=demo" ${TPP_ADD_URL}
    echo ""
  fi
  # Manual steps
  echo ""
  echo "------------------------"
  echo " ATENTION: MANUAL STEPS "
  echo "------------------------"
  echo ""
  echo -e "- If this project has a Jenkins, manually enable integration:\n  https://jira.local/secure/admin/jji/sites/0a79709cb03041588ca879faaded3869" 
  echo ""
  echo "- Change board administrator: https://jira.local/secure/RapidView.jspa?rapidView=${JIRA_BOARD_ID}"
  echo ""
  echo "- Change filter owner: https://jira.local/secure/admin/filters/ViewSharedFilters.jspa"
  echo ""
  echo "- Change workflow schema: https://jira.local/plugins/servlet/project-config/${JIRA_KEY}/workflows"
else
  echo ""
  echo "* Skipping Jira"
fi

#######################
### Rancher Install ###
#######################

echo ""
echo "-------------------------"
echo " Rundeck: Create Rancher "
echo "-------------------------"

if [[ "${RANCHER_INSTALL}" == "Yes" ]]; then
  # Creating project
  echo -e "\n* Creating project '${RANCHER_PROJECT}'\n"
  curl --silent --insecure --user "${RANCHER_API_USER}:${RANCHER_API_PASS}" -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"clusterId\":\"${RANCHER_CLUSTER_ID}\", \"name\":\"${RANCHER_PROJECT}\", \"namespaceId\":\"${RANCHER_PROJECT}\"}" "${RANCHER_API_URL}/projects" | python -m json.tool
  RANCHER_PROJECT_ID=`curl --silent --insecure --user "${RANCHER_API_USER}:${RANCHER_API_PASS}" -X GET -H "Accept: application/json" -H "Content-Type: application/json" "${RANCHER_API_URL}/projects?name=${RANCHER_PROJECT}" | python -m json.tool | grep id | head -n 1 | awk '{print $2}' | sed "s|\"||g" | sed "s|,||g"`
  RANCHER_PROJECT_URL="https://rancher.local/p/${RANCHER_PROJECT_ID}/workloads"
  # Creating namespaces
  echo -e "\n* Creating namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE1}'\n"
  /srv/config/tools/rancher/kubectl create namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE1}"
  /srv/config/tools/rancher/kubectl annotate namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE1}" field.cattle.io/projectId="${RANCHER_PROJECT_ID}"
  echo -e "\n* Creating namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE2}'\n"
  /srv/config/tools/rancher/kubectl create namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE2}"
  /srv/config/tools/rancher/kubectl annotate namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE2}" field.cattle.io/projectId="${RANCHER_PROJECT_ID}"
  echo -e "\n* Creating namespace '${RANCHER_PROJECT}-${RANCHER_NAMESPACE3}'\n"
  /srv/config/tools/rancher/kubectl create namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE3}"
  /srv/config/tools/rancher/kubectl annotate namespace "${RANCHER_PROJECT}-${RANCHER_NAMESPACE3}" field.cattle.io/projectId="${RANCHER_PROJECT_ID}"
  # Grantting permissions
  #echo -e "\n* Grantting permissions\n"
  # Adding registries
  #echo -e "\n* Adding Docker registries\n"
  # Registering in TPP
  if [ "${TPP}" == "Yes" ]; then
    echo -e "\n* Registering '${RANCHER_PROJECT_URL}' in TPP\n"
    curl --silent --insecure -X POST -F "conta=${TPP_CUSTOMER}" -F "projeto=${TPP_PROJECT}" -F "id_status=1" -F "id_ferramenta=RA" -F "link=${RANCHER_PROJECT_URL}" -F "tableconta=demo" ${TPP_ADD_URL}
    echo ""
  fi
  # Manual steps
  echo "------------------------"
  echo " ATENTION: MANUAL STEPS "
  echo "------------------------"
  echo ""
  echo -e "- Grant access for AD groups in: https://rancher.local/c/${RANCHER_CLUSTER_ID}/projects-namespaces/project/${RANCHER_PROJECT_ID}" 
  echo ""
  echo -e "- Add Docker Registries (hosted and group) in: https://rancher.local/p/${RANCHER_PROJECT_ID}/registries" 
else
  echo ""
  echo "* Skipping Rancher"
fi

#####################
### Sonar Install ###
#####################

echo ""
echo "-----------------------"
echo " Rundeck: Create Sonar "
echo "-----------------------"

if [[ "${SONAR_INSTALL}" == "Yes" ]]; then
  # Creating project
  echo -e "\n* Creating Sonar\n"
  SONAR_CUSTOMER_FORMATTED_NAME=`echo "${SONAR_CUSTOMER}" | sed "s| |%20|g"`
  SONAR_PROJECT_FORMATTED_NAME=`echo "${SONAR_PROJECT}" | sed "s| |%20|g"`
  SONAR_PROJECT_FORMATTED_FULL_NAME="${SONAR_CUSTOMER_FORMATTED_NAME}%20-%20${SONAR_PROJECT_FORMATTED_NAME}"
  curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/projects/create?key=${SONAR_KEY}&name=${SONAR_PROJECT_FORMATTED_FULL_NAME}&visibility=private"
  echo ""
  # Granting permissions
  SONAR_CUSTOMER_AD_GROUPS=`cat "${AD_GROUPS_FILE}" | grep "^${CUSTOMER}.*" | awk '{print $NF}' | sed "s|,|\n|g" | sed "s|@||g" | sed "s|=.*||g"`
  echo -e "\n* Granting permission to customer AD groups:\n\n${SONAR_CUSTOMER_AD_GROUPS}\n"
  for GROUP in `echo -e "${SONAR_CUSTOMER_AD_GROUPS}"` ; do
    echo "Granting permissions to group: ${GROUP}"
    SONAR_AD_GROUP_FORMATTED_NAME=`echo ${GROUP} | sed "s| |%20|g"`
    curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/user_groups/create?name=${SONAR_AD_GROUP_FORMATTED_NAME}" >/dev/null
    curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/permissions/add_group?projectKey=${SONAR_KEY}&groupName=${SONAR_AD_GROUP_FORMATTED_NAME}&permission=issueadmin"
    curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/permissions/add_group?projectKey=${SONAR_KEY}&groupName=${SONAR_AD_GROUP_FORMATTED_NAME}&permission=codeviewer"
    curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/permissions/add_group?projectKey=${SONAR_KEY}&groupName=${SONAR_AD_GROUP_FORMATTED_NAME}&permission=user"
    curl --silent --insecure --user "${SONAR_USER}:${SONAR_PASS}" -X POST "${SONAR_API_URL}/permissions/add_group?projectKey=${SONAR_KEY}&groupName=${SONAR_AD_GROUP_FORMATTED_NAME}&permission=scan"
  done
  # Registering in TPP
  if [ "${TPP}" == "Yes" ]; then
    echo -e "\n* Registering '${SONAR_PROJECT_URL}' in TPP\n"
    curl --silent --insecure -X POST -F "conta=${TPP_CUSTOMER}" -F "projeto=${TPP_PROJECT}" -F "id_status=1" -F "id_ferramenta=SO" -F "link=${SONAR_PROJECT_URL}" -F "tableconta=demo" ${TPP_ADD_URL}
    echo ""
  fi
else
  echo ""
  echo "* Skipping Sonar"
fi

# Notification variables

if [[ "${JENKINS_INSTALL}" == "Yes" ]]; then
  PROJECT="${CUSTOMER}/${JENKINS_JOB_NAME}"
else
  JENKINS_PROJECT_URL=""
fi

if [[ "${GITLAB_INSTALL}" == "Yes" ]]; then
  PROJECT="${CUSTOMER}/${GITLAB_PROJECT_GROUP}/${GITLAB_REPO}"
else
  GITLAB_PROJECT_URL=""
fi

if [[ "${JIRA_INSTALL}" == "Yes" ]]; then
  PROJECT="${CUSTOMER}/${JIRA_PROJECT}"
else
  JIRA_PROJECT_URL=""
fi

if [[ "${RANCHER_INSTALL}" == "Yes" ]]; then
  PROJECT="${CUSTOMER}/${RANCHER_PROJECT}"
else
  RANCHER_PROJECT_URL=""
fi

if [[ "${SONAR_INSTALL}" == "Yes" ]]; then
  PROJECT="${CUSTOMER}/${SONAR_PROJECT}"
else
  SONAR_PROJECT_URL=""
fi

#####################
### TPP Registers ###
#####################

echo ""
echo "------------------------"
echo " Rundeck: TPP Registers "
echo "------------------------"

mysql -E -u root -p<pass> -h devops toolsperproject -e "SELECT conta,projeto,link FROM demo WHERE conta = '${TPP_CUSTOMER}' AND projeto = '${TPP_PROJECT}'" | grep -v "^*" | sed "s|^  ||g" | sed "s|^ ||g" | sed "s|conta|\nconta|g"

###############
### Summary ###
###############

echo ""
echo "------------------"
echo " Rundeck: Summary "
echo "------------------"

NOTIFICATION_MESSAGE="
Date: `date`
Server: ${HOSTNAME}
User: ${SCRIPT_USER} (via Rundeck)

Project: ${PROJECT}

Docker:  ${DOCKER_HOSTED_PORT} ${DOCKER_GROUP_PORT}
Gitlab:  ${GITLAB_PROJECT_URL}
Jenkins: ${JENKINS_PROJECT_URL}
Jira:    ${JIRA_PROJECT_URL}
Rancher: ${RANCHER_PROJECT_URL}
Sonar:   ${SONAR_PROJECT_URL}"

echo -e "${NOTIFICATION_MESSAGE}"
echo -e "\nCompleted!\n"

exit 0
