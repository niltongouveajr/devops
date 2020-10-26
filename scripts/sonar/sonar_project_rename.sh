#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Conditions

if [ ${EUID} -ne 0 ]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

if [ $# -ne 3 ]; then
  echo -e "\n[ ERROR ] Invalid number of parameter.\n\nUse: $0 <VERSION> <KEY> <NEWNAME>\n\nExample: $0 7.9.3 KEY \"Customer - Project\"\n"
  exit 1
fi

# Run

su postgres -c "psql -d sonar-$1 -c \"UPDATE projects SET name = '$3', long_name = '$3' WHERE kee = '$2' AND scope = 'PRJ'\""
