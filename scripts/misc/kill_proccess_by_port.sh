#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# CONDITIONS

if [ $# -ne "1" ]; then
  echo -e "\n[ Error ] Usage: $0 <port>\n"
  exit 1
fi

# VARIABLES

PROCESS=`lsof -i:$1 -t`

# RUN

if [ -z "${PROCESS}" ]; then
  echo -e "\nNo process running on port $1. Nothing to do.\n"
  exit 0
else
  echo -e "\nThere is some processes running on port $1:\n\n${PROCESS}\n"
  echo -n "Would you want to kill them? (Y/N):"
  read ANSWER
  if [ "${ANSWER}" == "Y" ] || [ "${ANSWER}" == "y" ]; then
    lsof -i:$1 -t | xargs kill -9
    echo -e "\nProces ${PROCESS} killed.\n"
    exit 0
  else
    echo -e "\nOK. Nothing to do.\n"
    exit 0
  fi
fi
