#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Colors

bold=`tput bold`
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

# Disable Ctrl+C
#trap '' 2

# Conditions

if [ "${EUID}" -ne 0 ]; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] This script must be run as root.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

if [[ -z `ps -ef | grep postgres` ]]; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] Postgres proccess are not runing.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

# Header

echo "${bold}${green}"
echo "------------------------------"
echo " Postgres - Database Creation "
echo "------------------------------"
echo "${normal}"

# Database creation

echo -n "What name you want to give to the database? "
read DATABASE

if [[ -z "${DATABASE}" ]]; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] Database name can not be empty.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

if su postgres -c "psql -ltq" 2>/dev/null | awk '{print $1}' | grep -v "|" | grep -v ^$ | grep ${DATABASE} 2>/dev/null >/dev/null ; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] Database '${DATABASE}' already exists.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

#if [[ "${DATABASE}" =~ [^a-zA-Z0-9] ]]; then
#  trap 2
#  ERROR=`echo -e "${bold}${red}[ Error ] Special characters are not allowed.${normal}"`
#  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
#  sleep 30
#  exit 1
#fi

echo ""
echo -n "What username should have full access? "
read USER

if [[ -z "${USER}" ]]; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] Username can not be empty.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

#if [[ "${USER}" =~ [^a-zA-Z0-9] ]]; then
#  trap 2
#  ERROR=`echo -e "${bold}${red}[ Error ] Special characters are not allowed.${normal}"`
#  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
#  sleep 30
#  exit 1
#fi

echo ""
read -s -p "What password would like for this user? " PASSWORD

echo ""
echo ""
read -s -p "Confirm password: " PASSWORD_CONFIRM

if [[ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]]; then
  trap 2
  ERROR=`echo -e "\n${bold}${red}[ Error ] Password do not match.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

if [[ -z "${PASSWORD}" ]]; then
  trap 2
  ERROR=`echo -e "${bold}${red}[ Error ] Password can not be empty.${normal}"`
  echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
  sleep 30
  exit 1
fi

echo ""
echo ""
echo -n "Confirm database creation? [y/n]: "
read CONFIRM

if [[ "${CONFIRM}" == "Y" ]] || [[ "${CONFIRM}" == "y" ]]; then
  echo -e "\nCreating database...\n" ; sleep 1
  cp -pr postgres_create_database.pgsql postgres_create_database_running.pgsql 
  cp -pr postgres_create_user.pgsql postgres_create_user_running.pgsql 
  sed -i "s|DATABASE|${DATABASE}|g" postgres_create_database_running.pgsql
  sed -i "s|USER|${USER}|g" postgres_create_database_running.pgsql
  sed -i "s|PASSWORD|${PASSWORD}|g" postgres_create_database_running.pgsql
  sed -i "s|DATABASE|${DATABASE}|g" postgres_create_user_running.pgsql
  sed -i "s|USER|${USER}|g" postgres_create_user_running.pgsql
  sed -i "s|PASSWORD|${PASSWORD}|g" postgres_create_user_running.pgsql
  su postgres -c "psql -f postgres_create_user_running.pgsql" >/dev/null
# sudo -u postgres PGPASSWORD=${PASSWORD} psql -U ${USER} -x -c "select * from pg_user where usename='${USER}'"
  PGPASSWORD=${PASSWORD} psql -h localhost template1 ${USER} -c "select * from information_schema.tables" >/dev/null

  if [[ $? -ne 0 ]]; then
    trap 2
    ERROR=`echo -e "${bold}${red}[ Error ] Authentication failed.${normal}"`
    echo -e "\n${ERROR}\n\n(Press Ctrl+C to exit)"
    sleep 30
    exit 1
  else    
    su postgres -c "psql -f postgres_create_database_running.pgsql" >/dev/null
    echo -e "Created!\n"
  fi
else
  echo -e "\nOK. Nothing to do. Bye!\n"
  exit 0
fi

echo -n "Would you like to restore a SQL file in this database? [y/n]: "
read RESTORE

if [[ "${RESTORE}" == "Y" ]] || [[ "${RESTORE}" == "y" ]]; then
  echo ""
  echo -n "Type the full file path: "
  read FILE
  if [[ ! -f ${FILE} ]]; then
    WARNING=`echo -e "${bold}${yellow}[ Warning ] File not found. Nothing to do.${normal}"`
    echo -e "\n${WARNING}"
  else
    echo -e "\nRestoring the database ... If you have some error is because your SQL file is invalid.\n" ; sleep 1
    su postgres -c "psql ${DATABASE}" < ${FILE} >/dev/null
  fi
fi

echo -e "\nOK. Complete!\n"
exit 0
