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

VNET_RESOURCE_GROUP() {

if [[ "$(az group exists --name "${AZ_VNET_RESOURCE_GROUP}" --subscription "${AZ_SUBSCRIPTION}")" == "false" ]]; then
  echo ""
  echo "Creating resource group '${AZ_VNET_RESOURCE_GROUP}' on '${AZ_LOCATION}'..."
  az group create --name "${AZ_VNET_RESOURCE_GROUP}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --location "${AZ_LOCATION}" > /dev/null
fi

}

VNET_NSG() {

az network nsg show --name "${AZ_VNET_NSG_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating NSG '${AZ_VNET_NSG_NAME}' for VNET '${AZ_VNET_NAME}'..."
  az network nsg create --name "${AZ_VNET_NSG_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --location "${AZ_LOCATION}" > /dev/null
fi

}

VNET() {

az network vnet show --name "${AZ_VNET_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating VNET '${AZ_VNET_NAME}' with prefix '${AZ_VNET_PREFIX}'..."
  az network vnet create --name "${AZ_VNET_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --address-prefix "${AZ_VNET_PREFIX}"  > /dev/null
fi

}

VNET_SUBNET1() {

az network vnet subnet show --vnet-name "${AZ_VNET_NAME}" --name "${AZ_VNET_SUBNET1_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating subnet '${AZ_VNET_SUBNET1_NAME}' with prefix '${AZ_VNET_SUBNET1_PREFIX}'..."
  az network vnet subnet create --vnet-name "${AZ_VNET_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --name "${AZ_VNET_SUBNET1_NAME}" \
  --network-security-group "${AZ_VNET_NSG_NAME}" \
  --address-prefix "${AZ_VNET_SUBNET1_PREFIX}" > /dev/null
fi

}

VNET_SUBNET2() {

az network vnet subnet show --vnet-name "${AZ_VNET_NAME}" --name "${AZ_VNET_SUBNET2_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating subnet '${AZ_VNET_SUBNET2_NAME}' with prefix '${AZ_VNET_SUBNET2_PREFIX}'..."
  az network vnet subnet create --vnet-name "${AZ_VNET_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --name "${AZ_VNET_SUBNET2_NAME}" \
  --network-security-group "${AZ_VNET_NSG_NAME}" \
  --address-prefix "${AZ_VNET_SUBNET2_PREFIX}" > /dev/null
fi

}

VNET_SUBNET3() {

az network vnet subnet show --vnet-name "${AZ_VNET_NAME}" --name "${AZ_VNET_SUBNET3_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating subnet '${AZ_VNET_SUBNET3_NAME}' with prefix '${AZ_VNET_SUBNET3_PREFIX}'..."
  az network vnet subnet create --vnet-name "${AZ_VNET_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --name "${AZ_VNET_SUBNET3_NAME}" \
  --network-security-group "${AZ_VNET_NSG_NAME}" \
  --address-prefix "${AZ_VNET_SUBNET3_PREFIX}" > /dev/null
fi

}

VNET_SUBNET4() {

az network vnet subnet show --vnet-name "${AZ_VNET_NAME}" --name "${AZ_VNET_SUBNET4_NAME}" --resource-group "${AZ_VNET_RESOURCE_GROUP}" >/dev/null 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Creating subnet '${AZ_VNET_SUBNET4_NAME}' with prefix '${AZ_VNET_SUBNET4_PREFIX}'..."
  az network vnet subnet create --vnet-name "${AZ_VNET_NAME}" \
  --resource-group "${AZ_VNET_RESOURCE_GROUP}" \
  --name "${AZ_VNET_SUBNET4_NAME}" \
  --network-security-group "${AZ_VNET_NSG_NAME}" \
  --address-prefix "${AZ_VNET_SUBNET4_PREFIX}" > /dev/null
fi

}

#--delegations "Microsoft.ContainerInstance.containerGroups"

echo ""
echo "############"
echo "### VNET ###"
echo "############"
echo ""

echo -n "Confirm VNET creation? (Y/N): "
read CONFIRM

if [[ "${CONFIRM}" != "Y" ]] && [[ "${CONFIRM}" != "y" ]]; then
  echo -e "\n[ OK ] Aborted.\n"
  exit 0
fi

LOGIN
VNET_RESOURCE_GROUP
VNET_NSG
VNET
VNET_SUBNET1
VNET_SUBNET2
VNET_SUBNET3
VNET_SUBNET4

echo ""
echo "Done!"
echo ""
