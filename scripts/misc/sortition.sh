#!/bin/bash

# Author: Nilton R Gouvea Junior

# Variables

LUCKY_NUMBER=`echo $((1 + RANDOM % 9))`

# Run

if [[ "${LUCKY_NUMBER}" == "1" ]] || [[ "${LUCKY_NUMBER}" == "4" ]] || [[ "${LUCKY_NUMBER}" == "7" ]]; then
  echo "The lucky guy is: EDSON"
elif [[ "${LUCKY_NUMBER}" == "2" ]] || [[ "${LUCKY_NUMBER}" == "5" ]] || [[ "${LUCKY_NUMBER}" == "8" ]]; then
  echo "The lucky guy is: NATHANAEL"
elif [[ "${LUCKY_NUMBER}" == "3" ]] || [[ "${LUCKY_NUMBER}" == "6" ]] || [[ "${LUCKY_NUMBER}" == "9" ]]; then
  echo "The lucky guy is: NILTON"
fi
