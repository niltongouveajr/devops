#!/bin/bash

clear

# Author: Nilton R Gouvea Junior

# Variables

export ANSIBLE_USER="devops" 
export ANSIBLE_SCP_IF_SSH=y

# Conditions for execution

if [ "$USER" != "${ANSIBLE_USER}" ]; then
  echo -e "\n[Error] This script must be run by '${ANSIBLE_USER}' user.\n"
  exit 1
fi

# run

ansible -i ../inventories/vsdt_servers -m ping $1
