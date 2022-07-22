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

ACR() {

if [[ ! -z "$(az acr check-name --name "${AZ_ACR_NAME}" --subscription "${AZ_SUBSCRIPTION}" --output yaml | grep "nameAvailable" | awk '{print $2}' | grep "true")" ]]; then
  echo ""
  echo "Creating ACR '${AZ_ACR_NAME}' in '${AZ_RESOURCE_GROUP}' resource group..."
  az acr create --name "${AZ_ACR_NAME}" \
  --resource-group "${AZ_RESOURCE_GROUP}" \
  --location ${AZ_LOCATION} \
  --admin-enabled --sku basic > /dev/null
  az acr login --name "${AZ_ACR_NAME}" >/dev/null
fi

}

SERVICE_PRINCIPAL() {

if [[ -z "$(az ad sp list --display-name "${AZ_ACR_SP_NAME}" --output tsv 2>/dev/null)" ]]; then
  echo ""
  echo "Creating Service Principal..."
  AZ_ACR_ID=$(az acr show --name "${AZ_ACR_NAME}" --resource-group "${AZ_RESOURCE_GROUP}" --query "id" --output tsv 2>/dev/null)
  az ad sp create-for-rbac --name "${AZ_ACR_SP_NAME}" --scopes "${AZ_ACR_ID}" --role acrpull --query "password" --output tsv >/dev/null 2>/dev/null
  sleep 1
  AZ_ACR_SP_ID=$(az ad sp list --display-name "${AZ_ACR_SP_NAME}" --query "[].appId" --output tsv 2>/dev/null)
  AZ_ACR_SP_PASSWORD=$(az ad sp create-for-rbac --name "${AZ_ACR_SP_NAME}" --query password -o tsv)
  echo "Service principal ID: ${AZ_ACR_SP_ID}"
  echo "Service principal password: ${AZ_ACR_SP_PASSWORD}"
  #echo "${AZ_ACR_SP_PASSWORD}" | docker login --username "${AZ_ACR_SP_ID}" --password-stdin "${AZ_ACR_NAME}.azurecr.io"
fi

}

AGENT_IMAGE() {

echo ""	
echo -n "Would you like to build and push the agent image to registry? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" == "Y" ]] || [[ "${CONFIRM}" == "y" ]]; then
  echo ""
  echo -n "Type 'ubuntu-20.04' or 'windows-core-2019': " 
  read AZ_ACR_AGENT_SO
  if [[ "${AZ_ACR_AGENT_SO}" != "ubuntu-20.04" ]] && [[ "${AZ_ACR_AGENT_SO}" != "windows-core-2019" ]]; then
    echo -e "\n[ ERROR ] Invalid operating system. Skipping docker image creation.\n"
    exit 1
  else
    if [[ "${AZ_ACR_AGENT_SO}" == "ubuntu-20.04" ]]; then
      cd ../../agents/ubuntu-20.04	    
    elif [[ "${AZ_ACR_AGENT_SO}" == "windows-core-2019" ]]; then
      cd ../../agents/windows-core-2019    
    fi
    echo ""
    az acr login --name "${AZ_ACR_NAME}" >/dev/null
    docker build -t "${AZ_ACR_AGENT_IMAGE}:${AZ_ACR_AGENT_SO}" . 
    docker push "${AZ_ACR_AGENT_IMAGE}:${AZ_ACR_AGENT_SO}"
    #docker run -e AZP_URL="${AZ_DEVOPS_URL}" -e AZP_TOKEN="${AZ_DEVOPS_TOKEN}" -e AZP_POOL="${AZ_AGENT_POOL}" -e AZP_AGENT_NAME="${AZ_AGENT_PREFIX}" "${AZ_ACR_AGENT_IMAGE}:${AZ_ACR_AGENT_SO}"
  fi	  
else
  echo -e "\n[ OK ] Skipped.\n"
fi

}

ACI() {

az container show --name "${AZ_ACI_NAME}" --resource-group "${AZ_RESOURCE_GROUP}" >/dev/null 2>/dev/null	

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating ACI '${AZ_ACI_NAME}' in '${AZ_RESOURCE_GROUP}'..."
  echo ""
  echo -n "Type 'ubuntu-20.04' or 'windows-core-2019': " 
  read AZ_ACR_AGENT_SO
  if [[ "${AZ_ACR_AGENT_SO}" != "ubuntu-20.04" ]] && [[ "${AZ_ACR_AGENT_SO}" != "windows-core-2019" ]]; then
    echo -e "\n[ ERROR ] Invalid operating system. Skipping docker image creation.\n"
    exit 1
  fi
  AZ_ACR_SP_ID=$(az ad sp list --display-name "${AZ_ACR_SP_NAME}" --query "[].appId" --output tsv 2>/dev/null)
  AZ_ACR_SP_PASSWORD=$(az ad sp create-for-rbac --name "${AZ_ACR_SP_NAME}" --query password -o tsv)
  az container create --name "${AZ_ACI_NAME}" \
  --resource-group "${AZ_RESOURCE_GROUP}" \
  --image "${AZ_ACR_AGENT_IMAGE}:${AZ_ACR_AGENT_SO}" \
  --registry-username "${AZ_ACR_SP_ID}" \
  --registry-password "${AZ_ACR_SP_PASSWORD}" \
  --cpu "${AZ_EDA_CPU}" \
  --memory "${AZ_EDA_MEMORY}" \
  --vnet "${AZ_EDA_VNET_NAME}" \
  --subnet "${AZ_EDA_SUBNET_NAME}" \
  --environment-variables \
    AZP_URL="${AZ_EDA_DEVOPS_URL}" \
    AZP_TOKEN="${AZ_EDA_DEVOPS_TOKEN}" \
    AZP_POOL="${AZ_EDA_AGENT_POOL}" \
    AZP_AGENT_NAME="${AZ_EDA_AGENT_PREFIX}" \
    AZP_WORK=_work
fi

}

echo ""
echo "###########"
echo "### ACR ###"
echo "###########"
echo ""

echo -n "Confirm ACR creation? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" != "Y" ]] && [[ "${CONFIRM}" != "y" ]]; then
  echo -e "\n[ OK ] Aborted.\n"
  exit 0
fi

LOGIN
RESOURCE_GROUP
ACR
SERVICE_PRINCIPAL
AGENT_IMAGE

echo "Done!"
echo ""
