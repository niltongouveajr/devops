#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

export ANSIBLE_USER="ansible" 
export ANSIBLE_SCP_IF_SSH=y
export ANSIBLE_HOST_KEY_CHECKING=False

ANSIBLE_LOCATION="/srv/ansible"
ANSIBLE_SCRIPT=`echo $0 | xargs basename`
ANSIBLE_ROLES=`ls -1 ${ANSIBLE_LOCATION}/roles`
ANSIBLE_HOSTS_GROUPS=`echo $(cat ${ANSIBLE_LOCATION}/inventories/switches | grep "^\[" | sed "s|^\[||g" | sed "s|\]||g" | awk -F ":" '{print $1}' | sort)`
ANSIBLE_PLAYBOOKS=`ls -1 ${ANSIBLE_LOCATION}/*.yml | sed "s|${ANSIBLE_LOCATION}/||g" | sed "s|.yml||g"`
ANSIBLE_TAGS=`find ${ANSIBLE_LOCATION}/roles -name "main.yml" | grep -v ".template" | xargs grep "tag" | grep "tasks" | sort | sed "s|${ANSIBLE_LOCATION}/roles/||g" | sed "s|/tasks/main.yml:  tags||g" | sed "s|/tasks/main.yml:#  tags||g" | sed "s|\[\"||g" | sed "s|\"\]||g"`
ANSIBLE_TAGS_FILE="${ANSIBLE_LOCATION}/scripts/.ansible_tags.cfg"
ANSIBLE_LOGS_DATE=`date +"%Y%m%d%M%H"`


# Colors

bold=`tput bold`
italic=`tput sitm`
underline=`tput sgr 0 1`
normal=`tput sgr0`
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`

# Locale

LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8

# Conditions

if [ "$USER" != "${ANSIBLE_USER}" ]; then
  echo -e "\n[Error] This script must be run by '${ANSIBLE_USER}' user.\n"
  exit 1
fi

# Other Variables

cd ${ANSIBLE_LOCATION}/scripts && rm -rf .*.txt 2>/dev/null
echo -n > ${ANSIBLE_TAGS_FILE}

for i in `echo -e "${ANSIBLE_ROLES}"` ; do
  echo -e "${ANSIBLE_TAGS}" | grep "$i" >> ${ANSIBLE_LOCATION}/scripts/.$i.txt
done

for i in `ls -la ${ANSIBLE_LOCATION}/scripts | grep "txt" | awk '{print $NF}'` ; do
  ROLE=`echo "$i" | sed "s|^\.||g" | sed "s|.txt||g"`
  echo `cat "${ANSIBLE_LOCATION}/scripts/$i" | sed "s|${ROLE}: ||g"` > ${ANSIBLE_LOCATION}/scripts/$i.tmp
  mv ${ANSIBLE_LOCATION}/scripts/$i.tmp ${ANSIBLE_LOCATION}/scripts/$i
  sed -i "s|^|${underline}${ROLE}:${normal} |g" ${ANSIBLE_LOCATION}/scripts/$i
  cat ${ANSIBLE_LOCATION}/scripts/$i >> ${ANSIBLE_TAGS_FILE}
  echo "" >> ${ANSIBLE_TAGS_FILE}
done

sed -i "s|$| |g" ${ANSIBLE_TAGS_FILE}
rm -rf ${ANSIBLE_LOCATION}/scripts/.*.txt 2>/dev/null

ANSIBLE_MESSAGE="
${bold}${green}[ Usage ]${normal}

${bold}${ANSIBLE_SCRIPT} <playbook> <host_grp1,host_grp2,host_grpN,host1,host2,hostN> <tag1,tag2,tagN>${normal}

${italic}Example: ${ANSIBLE_SCRIPT} linux linux_all linux_connection_test${normal}

${bold}${green}[ Available Playbooks ]${normal}

${ANSIBLE_PLAYBOOKS}

${bold}${green}[ Available Hosts Groups ]${normal}

${ANSIBLE_HOSTS_GROUPS}

${bold}${green}[ Available Roles Tags ]${normal}

`cat ${ANSIBLE_TAGS_FILE} | grep -v ^$`
"

# Run

echo "${bold}${green}"
echo "--------------------------"
echo " Ansible - IT Environment "
echo "--------------------------"
echo -n "${normal}"

if [ $# -eq "3" ]; then
  ANSIBLE_PLAYBOOK=$1
  ANSIBLE_HOSTS_GROUPS=$2
  ANSIBLE_ROLES_TAGS=$3
else
  echo -e "${ANSIBLE_MESSAGE}"
  echo -n "Playbook: "
  read ANSIBLE_PLAYBOOK
  echo -n "Hosts Group(s): "
  read ANSIBLE_HOSTS_GROUPS
  echo -n "Roles Tag(s): "
  read ANSIBLE_ROLES_TAGS
fi

echo -e "\n${cyan}ansible-playbook ${ANSIBLE_LOCATION}/${ANSIBLE_PLAYBOOK}.yml -i ${ANSIBLE_LOCATION}/inventories/it_environment --limit \"${ANSIBLE_HOSTS_GROUPS}\" --tags \"${ANSIBLE_ROLES_TAGS}\"${normal}" > ${ANSIBLE_LOCATION}/logs/ansible_run.${ANSIBLE_LOGS_DATE}.log

if [[ $1 != "switches" ]]; then
  unbuffer ansible-playbook ${ANSIBLE_LOCATION}/${ANSIBLE_PLAYBOOK}.yml -i ${ANSIBLE_LOCATION}/inventories/it_environment --limit "${ANSIBLE_HOSTS_GROUPS}" --tags "${ANSIBLE_ROLES_TAGS}" 2>&1 | tee -a ${ANSIBLE_LOCATION}/logs/ansible_run.${ANSIBLE_LOGS_DATE}.log
else
  ansible-playbook ${ANSIBLE_LOCATION}/${ANSIBLE_PLAYBOOK}.yml -i ${ANSIBLE_LOCATION}/inventories/it_environment --limit "${ANSIBLE_HOSTS_GROUPS}" --tags "${ANSIBLE_ROLES_TAGS}"
fi

# Logs

mv ${ANSIBLE_LOCATION}/$1.retry ${ANSIBLE_LOCATION}/logs/$1.retry.${ANSIBLE_LOGS_DATE} 2>/dev/null

echo -e "Completed!\n"
exit 0
