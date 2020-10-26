#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# MONKEY TEST 

##############
### HEADER ###
##############

echo ""
echo "-------------"
echo " MONKEY TEST "
echo "-------------"

###################
#### CONDITIONS ###
###################

#HOUR=`date +"%k"`

#if [[ "${HOUR}" -ge "0" ]] && [[ "${HOUR}" -lt "1" ]]; then
#  sleep 0
#else
#  if [[ "$6" == "--force" ]]; then
#    sleep 0
#  else
#    echo -e "\n[ WARN ] The Monkey Test script should run only between 00h00 and 01h00.\n"
#    exit 0
#  fi
#fi

################################
### VARIABLES AND PARAMETERS ###
################################

ADB_PATH="/srv/hudson/android/android-sdk-linux-complete/platform-tools"

APK_FILE=$1
PACKAGE=$2
EVENTS=$3
DELAY=$4
OTHERS=$5

#APK_FILE="${WORKSPACE}/bin/MonkeyTrial.apk"
#PACKAGE="com.example.monkeytrial"
#EVENTS="5"
#DELAY="300"
#OTHERS="--pct-trackball 0 --pct-touch 30 --pct-motion 30 --pct-majornav 20 --pct-appswitch 10 --pct-anyevent 10"

echo -e "\nHow to use:\n"
echo -e "$0 <APK_FILE> <PACKAGE> <EVENTS> <DELAY> <OTHERS>"
echo -e "\nExample:\n"
echo -e "$0 bin/MonkeyTrial.apk com.example.monkeytrial 250000 300\" --pct-trackball 0 --pct-touch 30 --pct-motion 30 --pct-majornav 20 --pct-appswitch 10 --pct-anyevent 10\"\n"

##################
### CONDITIONS ###
##################

if [[ $# -lt 4 ]]; then
  echo -e "[ Error ] Invalid parameters.\n"
  exit 0
fi

if [[ -z ${PACKAGE} ]]; then
  echo -e "[ Error ] Package can not be empty.\n"
  exit 1
fi

if [[ -z ${EVENTS} ]]; then
  echo -e "[ Error ] Events can not be empty.\n"
  exit 1
fi

if [[ -z ${DELAY} ]]; then
  echo -e "[ Error ] Delay can not be empty.\n"
  exit 1
fi

if [[ "${INTERFACE}" == "WIFI" ]] && [[ -z "${ANDROID_SERIAL}" ]]; then
  echo -e "Error: Serial can not be empty in Wifi mode!\n"
  exit 1
fi

if [[ "${INSTALL}" == "true" ]] && [[ -z "${DATA}" ]]; then
  echo -e "Error: You checked 'install' option but dit not choose an APK.\n"
  exit 1
fi

#####################
### SELECT DEVICE ###
#####################

echo "-----------------"
echo " ANDROID DEVICES "
echo "-----------------"
echo ""
${ADB_PATH}/adb devices

export ADB_DEVICES_ALL="/var/lib/hudson/.android/adb_devices_all.txt"
export ADB_DEVICES_INUSE="/var/lib/hudson/.android/adb_devices_inuse.txt"

echo -e "`${ADB_PATH}/adb devices | tail -n +2 | cut -sf 1`" > ${ADB_DEVICES_ALL}

if [ ! -f ${ADB_DEVICES_INUSE} ]; then
  touch ${ADB_DEVICES_INUSE}
fi

######################
### WIFI INTERFACE ###
######################

if [[ "${INTERFACE}" == "WIFI" ]] && [[ ! -z "${ANDROID_SERIAL}" ]]; then
  if [[ ! -z `${ADB_PATH}/adb devices | grep "^${ANDROID_SERIAL}"` ]]; then
    WLAN_IP=`${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop dhcp.wlan0.ipaddress`
    WLAN_PORT=`shuf -i 5000-9999 -n 1`
    echo `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop dhcp.wlan0.ipaddress` `shuf -i 5000-9999 -n 1`
    echo $WLAN_IP > wlan.txt.tmp
    echo $WLAN_PORT >> wlan.txt.tmp
    dos2unix wlan.txt.tmp
    WLAN_IP_FORMAT=`cat wlan.txt.tmp | head -n 1`
    WLAN_PORT_FORMAT=`cat wlan.txt.tmp | tail -n 1`
    echo "$WLAN_IP_FORMAT:$WLAN_PORT_FORMAT" > wlan.txt
    WLAN=`cat wlan.txt`

    ${ADB_PATH}/adb -s "${ANDROID_SERIAL}" tcpip "${WLAN_PORT}"
    ${ADB_PATH}/adb -s "${ANDROID_SERIAL}" connect "${WLAN_IP_FORMAT}:${WLAN_PORT_FORMAT}"
    SERIAL="${ANDROID_SERIAL}"
    ANDROID_SERIAL="${WLAN_IP_FORMAT}:${WLAN_PORT_FORMAT}"
    echo ${ANDROID_SERIAL} >> ${ADB_DEVICES_INUSE}
  else
    echo -e "\nError: Device not found!\n"
    exit 1
  fi
fi

#####################################
### ANDROID SERIAL AUTO SELECTION ###
#####################################

if [[ -z "${ANDROID_SERIAL}" ]]; then
  for SERIAL in `cat ${ADB_DEVICES_ALL}`; do
    if [[ -z `cat ${ADB_DEVICES_INUSE} | grep "${SERIAL}"` ]]; then
      echo ${SERIAL} >> ${ADB_DEVICES_INUSE}
      export ANDROID_SERIAL="${SERIAL}"
      break
    fi
    sleep 0
  done
else

#######################################
### ANDROID SERIAL MANUAL SELECTION ###
#######################################

  if [[ -z `${ADB_PATH}/adb devices | grep "^${ANDROID_SERIAL}"` ]]; then
    echo -e "\nError: Device not found!\n"
    exit 1
  fi

  if [[ ! -z `cat ${ADB_DEVICES_INUSE} | grep "^${ANDROID_SERIAL}$"` ]]; then
    echo -e "\nError: Device already in use!\n"
    exit 1
  else
    echo ${ANDROID_SERIAL} >> ${ADB_DEVICES_INUSE}
  fi

fi

if [[ -z `echo ${ANDROID_SERIAL}` ]]; then
  echo -e "\nError: No devices available!\n"
  exit 1
fi

echo -e "ANDROID_SERIAL (selected device): ${ANDROID_SERIAL}\n"

###############################
### REMEMBER ANDROID SERIAL ###
###############################

echo "ADB_DEVICES_INUSE=${ADB_DEVICES_INUSE}
ANDROID_SERIAL=${ANDROID_SERIAL}" > selected_device.txt

#######################
### RUN MONKEY TEST ###
#######################

TIMER_START=$(date +%s)

echo "--------------"
echo " START LOGCAT "
echo "--------------"
echo ""
sleep 1
${ADB_PATH}/adb -s ${ANDROID_SERIAL} logcat -v raw *:W > logcat.txt & echo $! > logcatPID.txt
echo "Success"
echo ""

if [[ "${INSTALL}" == "true" ]] || [[ -z "${INSTALL}" ]]; then
  echo "-------------------"
  echo " UNINSTALL PACKAGE "
  echo "-------------------"
  echo ""
  sleep 1
  ${ADB_PATH}/adb -s ${ANDROID_SERIAL} uninstall ${PACKAGE}
  echo ""

  echo "-----------------"
  echo " INSTALL PACKAGE "
  echo "-----------------"
  echo ""
  sleep 1
  ${ADB_PATH}/adb -s ${ANDROID_SERIAL} install -r "${APK_FILE}"
  echo ""
fi

echo "-----------------"
echo " RUN MONKEY TEST "
echo "-----------------"
echo ""
sleep 1
${ADB_PATH}/adb shell monkey -v -s `tr -cd '0-9' < /dev/urandom | fold -w3 | head -n1` --throttle ${DELAY} -p ${PACKAGE} ${EVENTS} ${OTHERS} -d ${ANDROID_SERIAL} | tee monkey.txt

TIMER_END=$(date +%s)
TIMER_SECS=$((${TIMER_END} - ${TIMER_START}))
TIMER_RESULT=`printf '%dh:%dm:%ds\n' $((${TIMER_SECS}/3600)) $((${TIMER_SECS}%3600/60)) $((${TIMER_SECS}%60))`

echo ""

DEVICE_INFO="
*+TEST SUMMARY+*

Test running time:    ${TIMER_RESULT}
Amount of events:     ${EVENTS}
Package:              ${PACKAGE}
Application language: `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.product.locale.language`
Application version:  `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell dumpsys package ${PACKAGE} | grep versionName | awk -F "=" '{print $2}'`
Report generated:     `date`

*+DEVICE INFO+*

Product name:         `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.semc.product.name`
Model:                `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.product.model`
Manufacturer:         `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.product.brand`
SW version:           `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.build.id`
CDF:                  `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.cst.prm`
Region:               `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.product.locale.region`
Serial number:        `${ADB_PATH}/adb -s ${ANDROID_SERIAL} shell getprop ro.serialno`"

echo -e "${DEVICE_INFO}" | tee testsummary.txt
echo ""

#######################
### UNSELECT DEVICE ###
#######################

sed -i "s|`echo ${ANDROID_SERIAL}`||g" ${ADB_DEVICES_INUSE}
sed -i '/^$/d' ${ADB_DEVICES_INUSE}

if [[ "${INTERFACE}" == "WIFI" ]]; then
  ${ADB_PATH}/adb -s ${SERIAL} disconnect ${ANDROID_SERIAL}
fi
