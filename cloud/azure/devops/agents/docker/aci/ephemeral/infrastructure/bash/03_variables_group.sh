#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

source ./variables.sh

LOGIN() {

az account show >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Proceeding to login..."
  az login >/dev/null 2>/dev/null
  az account set --subscription "${AZ_SUBSCRIPTION}" >/dev/null
fi

}

echo -n "Type project name: "
read AZURE_DEVOPS_PROJECT
echo -n "Type PAT with variable group (read, create & manage) and agent pools (read & manage) scope permission: "
read AZURE_DEVOPS_EXT_PAT 

VARIABLE_GROUP() {

echo ""
echo "Creating variable group '${AZ_VARIABLE_GROUP_NAME}' in project '${AZURE_DEVOPS_PROJECT}'..."
echo ""

#if [[ -z `AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group list --project "${AZURE_DEVOPS_PROJECT}" --org "${AZ_VARIABLE_GROUP_ORG}" --query "[].name" -o tsv 2>/dev/null | grep "^${AZ_VARIABLE_GROUP_NAME}$"` ]]; then

  #AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group list --project "${AZURE_DEVOPS_PROJECT}" --org "${AZ_VARIABLE_GROUP_ORG}" --query "[].name" -o tsv 2>/dev/null | grep "^${AZ_VARIABLE_GROUP_NAME}$"

  AZ_VARIABLE_GROUP_VARIABLES="$(sed '0,/^# Ephemeral Docker Agent (variable group)$/d' ./variables.sh)"

  AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group create --name "${AZ_VARIABLE_GROUP_NAME}" --description "${AZ_VARIABLE_GROUP_DESCRIPTION}" --project "${AZURE_DEVOPS_PROJECT}" --subscription "${AZ_SUBSCRIPTION}" --org "${AZ_VARIABLE_GROUP_ORG}" --authorize "${AZ_VARIABLE_GROUP_AUTHORIZE}" --variables test=test 2>/dev/null

  AZ_VARIABLE_GROUP_ID=`AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group list --group-name "${AZ_VARIABLE_GROUP_NAME}" --project "${AZURE_DEVOPS_PROJECT}" --subscription "${AZ_SUBSCRIPTION}" --org "${AZ_VARIABLE_GROUP_ORG}" --query "[].id" -o tsv 2>/dev/null` 

  while IFS= read -r VARIABLE ; do
    VARIABLE_NAME=`echo "${VARIABLE}" | awk -F "=" '{print $1}'`
    VARIABLE_VALUE=`echo "${VARIABLE}" | awk -F "=" '{print $2}' | sed "s|\"||g"`
    echo "Variable name : ${VARIABLE_NAME}"
    echo "Variable value: ${VARIABLE_VALUE}"
    AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group variable create --group-id "${AZ_VARIABLE_GROUP_ID}" --project "${AZURE_DEVOPS_PROJECT}" --subscription "${AZ_SUBSCRIPTION}" --org "${AZ_VARIABLE_GROUP_ORG}" --name "${VARIABLE_NAME}" --value "${VARIABLE_VALUE}" --only-show-errors
done <<< "${AZ_VARIABLE_GROUP_VARIABLES}"

    AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group variable update --group-id "${AZ_VARIABLE_GROUP_ID}" --project "${AZURE_DEVOPS_PROJECT}" --subscription "${AZ_SUBSCRIPTION}" --org "${AZ_VARIABLE_GROUP_ORG}" --name "AZ_EDA_DEVOPS_TOKEN" --value "${AZURE_DEVOPS_EXT_PAT}" --secret "true"

    AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT}" az pipelines variable-group variable delete --group-id "${AZ_VARIABLE_GROUP_ID}" --project "${AZURE_DEVOPS_PROJECT}" --subscription "${AZ_SUBSCRIPTION}" --org "${AZ_VARIABLE_GROUP_ORG}" --name "test" --yes >/dev/null 2>/dev/null


#fi

} 

echo ""
echo "######################"
echo "### VARIABLE GROUP ###"
echo "######################"
echo ""

echo -n "Confirm pipeline variable-group creation? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" != "Y" ]] && [[ "${CONFIRM}" != "y" ]]; then
  echo -e "\n[ OK ] Aborted.\n"
  exit 0
fi

LOGIN
VARIABLE_GROUP

echo "Done!"
echo ""
