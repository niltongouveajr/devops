#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

SDK_DIR="/srv/hudson/android"

# Conditions

if [ ${HOSTNAME} != "jenkins01" ]; then
  echo -e "\n[ Error ] Invalid hostname. Run in 'jenkins01'\n"
  exit 1
fi

if [ ! -d ${SDK_DIR} ]; then
  echo -e "\n[ Error ] The directory $SDK_DIR does not exists.\n"
  exit 1
fi

if [ ! -L ${SDK_DIR}/android-sdk-linux-complete ]; then
  echo -e "\n[ Error ] symbolic link 'android-sdk-linux-complete' does not exists.\n"
  exit 1
fi

# Run

cd ${SDK_DIR}

AVAILABLE=`ls -la | grep ^d | grep -v "\.$" | awk '{print $NF}'`

# Header

echo -e "\nANDROID SDK AVAILABLE:\n----------------------\n"
echo -e "${AVAILABLE}"
echo ""
echo -n "Choose one: "
read CHOICE

if [ -z `echo -e "${AVAILABLE}" | grep "^${CHOICE}$"` ]; then 
  echo -e "\n[ Error ] Your choice does not match an available SDK.\n"
  exit 1
else
  SDK_PATH="${SDK_DIR}/${CHOICE}/tools"
fi  

echo ""
echo "--------------"
echo " Package List "
echo "--------------"
echo ""

# Run

${SDK_PATH}/android list sdk --no-ui -a

echo ""
echo -n "--> Enter the numbers of the packages you want to update. (For more than one, separate by a comma): "
read PACKAGES

if [ -z ${PACKAGES} ]; then
  echo -e "\n[ Error ] Packages can not be empty.\n"
  exit 1
fi

echo ""
echo -n "--> Confirm update? (y/n): "
read CONFIRM

if [ ${CONFIRM} == "Y" ] || [ ${CONFIRM} == "y" ]; then
  echo -e "\nRunning command: ${SDK_PATH}/android update sdk --no-ui -a --filter \"${PACKAGES}\"\n"
  sleep 3
  ${SDK_PATH}/android update sdk --no-ui -a --filter "${PACKAGES}"
  echo -e "\nCompleted!\n"
else
  echo -e "\nOK. Nothing to do.\n"
  exit 0
fi
