#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# General
AZ_SUBSCRIPTION="DevOps"
AZ_RESOURCE_GROUP="DevOps"
AZ_LOCATION="brazilsouth"

# VNET
AZ_VNET_NSG_NAME="DevOps"
AZ_VNET_RESOURCE_GROUP="DevOps-VNET"
AZ_VNET_NAME="DevOps"
AZ_VNET_PREFIX="10.0.0.0/24"
AZ_VNET_SUBNET1_NAME="storage"
AZ_VNET_SUBNET1_PREFIX="10.0.0.0/26"
AZ_VNET_SUBNET2_NAME="data"
AZ_VNET_SUBNET2_PREFIX="10.0.0.64/26"
AZ_VNET_SUBNET3_NAME="compute"
AZ_VNET_SUBNET3_PREFIX="10.0.0.128/26"
AZ_VNET_SUBNET4_NAME="azure-pipelines-agents"
AZ_VNET_SUBNET4_PREFIX="10.0.0.192/26"

# ACR
AZ_ACR_NAME="devops"
AZ_ACR_SP_NAME="devops-service-principal"
AZ_ACR_AGENT_IMAGE="${AZ_ACR_NAME}.azurecr.io/devops/azure/azure-pipelines-agent"

# ACI
AZ_ACI_NAME="azure-pipelines-agent"

# Keyvault
AZ_KEYVAULT_NAME="DevOps"

# Variable Group
AZ_VARIABLE_GROUP_NAME="Ephemeral Docker Agent"
AZ_VARIABLE_GROUP_AUTHORIZE="true"
AZ_VARIABLE_GROUP_DESCRIPTION=""
AZ_VARIABLE_GROUP_ORG="https://dev.azure.com/DevOps"

# Ephemeral Docker Agent (variable group)
AZ_EDA_AGENT_POOL="Ephemeral Docker Agent"
AZ_EDA_AGENT_PREFIX="docker-agent-"
AZ_EDA_CONTAINER_REGISTRY="ACR"
AZ_EDA_CPU="2"
AZ_EDA_DEVOPS_TOKEN=""
AZ_EDA_DEVOPS_URL="https://dev.azure.com/DevOps"
AZ_EDA_IMAGE_NAME="devops.azurecr.io/devops/azure/azure-pipelines-agent:ubuntu-20.04"
AZ_EDA_LOCATION="brazilsouth"
AZ_EDA_MEMORY="4.0"
AZ_EDA_OS_TYPE="Linux"
AZ_EDA_POOL="Self-Hosted Linux"
AZ_EDA_RESOURCE_GROUP_NAME="DevOps"
AZ_EDA_SKIP_CONTAINER_DELETION="false"
AZ_EDA_SUBNET_NAME="azure-pipelines-agents"
AZ_EDA_SUBSCRIPTION="Azure Resource Manager"
AZ_EDA_TIMEOUT_AGENT_ONLINE="180"
AZ_EDA_USE_GLOBAL_CONFIG="false"
AZ_EDA_VNET_NAME="DevOps"
AZ_EDA_VNET_RESOURCE_GROUP_NAME="DevOps-VNET"
