#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

AZ_ACR_NAME="devops"
AZ_ACR_SP_NAME="acr-service-principal"
AZ_ACR_AGENT_IMAGE="${AZ_ACR_NAME}.azurecr.io/devops/azure/azure-pipeline-agent:ubuntu-20.04"

AZ_DEVOPS_URL="https://dev.azure.com/DevOps"
AZ_DEVOPS_TOKEN=""
AZ_DEVOPS_POOL_NAME="Docker"
AZ_DEVOPS_AGENT_NAME="docker-ubuntu-agent-01"

# Run

docker run -e AZP_URL="${AZ_DEVOPS_URL}" -e AZP_TOKEN="${AZ_DEVOPS_TOKEN}" -e AZP_POOL="${AZ_DEVOPS_POOL_NAME}" -e AZP_AGENT_NAME="${AZ_DEVOPS_AGENT_NAME}" "${AZ_ACR_AGENT_IMAGE}"
