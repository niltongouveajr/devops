#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

export AWS_CREDENTIALS_FILE="/home/vntniju/github/terraform/aws/.aws/credentials"

if [[ ! -f "${AWS_CREDENTIALS_FILE}" ]]; then
  echo -e "\n[ Error ] Missing credentials file '${AWS_CREDENTIALS_FILE}'\n"
  exit 1
fi

export AWS_ACCESS_KEY_ID=$(cat "${AWS_CREDENTIALS_FILE}" | grep "aws_access_key_id" | awk -F "\"" '{print $2}')
export AWS_SECRET_ACCESS_KEY=$(cat "${AWS_CREDENTIALS_FILE}" | grep "aws_secret_access_key" | awk -F "\"" '{print $2}')

# Conditions

if [[ $# -ne 4 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <key-id> <region> <file-input> <file-output>\n"
  exit 1
fi

if [[ ! -f $3 ]]; then
  echo -e "\n [ Error ] Missing file '$3'.\n"
  exit 1
fi

# Run

aws kms encrypt --key-id $1 --region $2 --plaintext fileb://$3 --output text --query CiphertextBlob > $4.encrypted
