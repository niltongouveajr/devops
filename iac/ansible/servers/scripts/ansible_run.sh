#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

export ANSIBLE_USER="devops" 
export ANSIBLE_SCP_IF_SSH=y
export ANSIBLE_HOST_KEY_CHECKING=False

ANSIBLE_LOCATION=`dirname "$(readlink -f "$0")" | sed "s|/scripts||g"`
ANSIBLE_INVENTORY_FILE="vsdt_servers"
ANSIBLE_SCRIPT=`echo $0 | xargs basename`
ANSIBLE_ROLES=`ls -1 ${ANSIBLE_LOCATION}/roles`
ANSIBLE_HOSTS_GROUPS=`echo $(cat ${ANSIBLE_LOCATION}/inventories/${ANSIBLE_INVENTORY_FILE} | grep "^\[" | sed "s|^\[||g" | sed "s|\]||g" | awk -F ":" '{print $1}' | sort)`
ANSIBLE_PLAYBOOKS=`ls -1 ${ANSIBLE_LOCATION}/playbooks/*.yml | awk -F "/" '{print $NF}' | sed "s|.yml||g"`
ANSIBLE_TAGS=`find ${ANSIBLE_LOCATION}/roles -name "main.yml" | xargs grep "tag" | grep "tasks" | sort | sed "s|${ANSIBLE_LOCATION}/roles/||g" | sed "s|/tasks/main.yml:  tags||g" | sed "s|/tasks/main.yml:#  tags||g" | sed "s|\[\"||g" | sed "s|\"\]||g"`
ANSIBLE_TAGS_FILE="${ANSIBLE_LOCATION}/scripts/.ansible_tags.cfg"
ANSIBLE_LOGS_DATE=`date +"%Y%m%d%H%M"`


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

if [[ "${USER}" != "${ANSIBLE_USER}" ]]; then
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

sed -i "s| |,|g" ${ANSIBLE_TAGS_FILE}
rm -rf ${ANSIBLE_LOCATION}/scripts/.*.txt 2>/dev/null

ANSIBLE_MESSAGE="
${bold}${green}[ Usage ]${normal}

${bold}${ANSIBLE_SCRIPT} <playbook> <host_grp1,host_grp2,host_grpN,host1,host2,hostN> <tag1,tag2,tagN>${normal}

${bold}${green}[ Available Playbooks ]${normal}

${ANSIBLE_PLAYBOOKS}

${bold}${green}[ Available Hosts Groups ]${normal}

${ANSIBLE_HOSTS_GROUPS}

${bold}${green}[ Available Roles Tags ]${normal}

`cat ${ANSIBLE_TAGS_FILE} | grep -v ^$`"

# Run

echo "${bold}${green}"
echo "------------------------------"
echo " Ansible - DevOps Environment "
echo "------------------------------"
echo -n "${normal}"

if [ $# -eq "3" ]; then
  ANSIBLE_PLAYBOOK=$1
  ANSIBLE_HOSTS_GROUPS=$2
  ANSIBLE_ROLES_TAGS=$3
  echo ""
  echo "Playbook: $1"
  echo "Hosts Group(s): $2"
  echo "Roles Tag(s): $3"
else
  echo -e "${ANSIBLE_MESSAGE}"
  echo ""
  echo -n "Playbook: "
  read ANSIBLE_PLAYBOOK
  echo -n "Hosts Group(s): "
  read ANSIBLE_HOSTS_GROUPS
  echo -n "Roles Tag(s): "
  read ANSIBLE_ROLES_TAGS
fi

if [ "${ANSIBLE_ROLES_TAGS}" == "all" ]; then
  ANSIBLE_ROLES_TAGS=`echo $(find ${ANSIBLE_LOCATION}/roles -name main.yml | grep "tasks" | xargs cat | grep tags | sed "s| ||g" | grep -v ^# | sed "s|tags:\[\"||g" | sed "s|\"\]||g" | sort -u | sed "s|$|,|g")`
fi 

echo -e "\nCommand: ${cyan}ansible-playbook ${ANSIBLE_LOCATION}/playbooks/${ANSIBLE_PLAYBOOK}.yml -i ${ANSIBLE_LOCATION}/inventories/${ANSIBLE_INVENTORY_FILE} --limit \"${ANSIBLE_HOSTS_GROUPS}\" --tags \"${ANSIBLE_ROLES_TAGS}\"${normal}\n" | tee ${ANSIBLE_LOCATION}/logs/ansible_run.${ANSIBLE_LOGS_DATE}.log

echo -n "Confirm execution? (Y/N): "
read CONFIRM

if [ "${CONFIRM}" != "Y" ] && [ "${CONFIRM}" != "y" ]; then
  echo -e "\nAborted.\n"
  exit 0
fi

ansible-playbook ${ANSIBLE_LOCATION}/playbooks/${ANSIBLE_PLAYBOOK}.yml -i ${ANSIBLE_LOCATION}/inventories/${ANSIBLE_INVENTORY_FILE} --limit "${ANSIBLE_HOSTS_GROUPS}" --tags "${ANSIBLE_ROLES_TAGS}" 2>&1 | tee -a ${ANSIBLE_LOCATION}/logs/ansible_run.${ANSIBLE_LOGS_DATE}.log

# Logs

mv ${ANSIBLE_LOCATION}/$1.retry ${ANSIBLE_LOCATION}/logs/$1.retry.${ANSIBLE_LOGS_DATE} 2>/dev/null

echo -e "Completed!\n"
exit 0
