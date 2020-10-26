#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

SDK_DIR="/srv/hudson/android"

# Conditions

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

echo -e "\nANDROID SDK AVAILABLE:\n----------------------\n"
echo -e "${AVAILABLE}"
echo ""
echo -n "Choose one: "
read CHOICE

if [ -z `echo -e "${AVAILABLE}" | grep "^${CHOICE}$"` ]; then 
  echo -e "\n[ Error ] Your choice does not match an available SDK.\n"
  exit 1
else
  rm ${SDK_DIR}/android-sdk-linux-complete
  ln -s ${CHOICE} android-sdk-linux-complete
  chown -h nobody: android-sdk-linux-complete
  echo -e "\nComplete!\n"
fi  

