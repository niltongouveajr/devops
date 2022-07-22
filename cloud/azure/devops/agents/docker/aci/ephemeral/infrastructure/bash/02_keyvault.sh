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

RESOURCE_GROUP() {

if [[ "$(az group exists --name "${AZ_RESOURCE_GROUP}" --subscription "${AZ_SUBSCRIPTION}")" == "false" ]]; then
  echo ""
  echo "Creating resource group '${AZ_RESOURCE_GROUP}' on '${AZ_LOCATION}'..."
  az group create --name "${AZ_RESOURCE_GROUP}" \
  --resource-group "${AZ_RESOURCE_GROUP}" \
  --location "${AZ_LOCATION}" > /dev/null
fi

}

KEYVAULT() {

#if [[ -z "$(az keyvault list --resource-group "${AZ_RESOURCE_GROUP}" | grep "name" | awk '{print $2}' | sed "s|\"||g" | sed "s|,||g" | sort -u | grep "^${AZ_KEYVAULT_NAME}$")" ]]; then
  echo ""
  echo "Creating Keyvault '${AZ_KEYVAULT_NAME}' in '${AZ_RESOURCE_GROUP}' resource group..."
  az keyvault purge --name "${AZ_KEYVAULT_NAME}" --subscription "${AZ_SUBSCRIPTION}" --no-wait 2>/dev/null
  az keyvault create --name "${AZ_KEYVAULT_NAME}" --resource-group "${AZ_RESOURCE_GROUP}" 2>/dev/null

  SECRETS="$(sed '0,/^# Ephemeral Docker Agent (variable group)$/d' ./variables.sh)"

  while IFS= read -r SECRET ; do
    SECRET_NAME="$(echo "${SECRET}" | awk -F "=" '{print $1}' | sed "s|_|-|g")"
    SECRET_VALUE="$(echo "${SECRET}" | awk -F "\"" '{print $2}')"
    az keyvault secret set \
    --vault-name "${AZ_KEYVAULT_NAME}" \
    --name "${SECRET_NAME}" \
    --value "${SECRET_VALUE}" >/dev/null
  done <<< "${SECRETS}"
#fi

} 

echo ""
echo "################"
echo "### KEYVAULT ###"
echo "################"
echo ""

echo -n "Confirm Keyvault creation? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" != "Y" ]] && [[ "${CONFIRM}" != "y" ]]; then
  echo -e "\n[ OK ] Aborted.\n"
  exit 0
fi

LOGIN
RESOURCE_GROUP
KEYVAULT

echo "Done!"
echo ""
