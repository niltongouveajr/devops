#!/bin/bash
clear

# Author: Nilton R Gouvea Jr

# Variables

ACCOUNT=$1
NAME=$1

LDAP_HOST="<host>"
LDAP_BIND_USER="<user>"
LDAP_BIND_PASS="<pass>"
LDAP_BASE_DN="<basedn>"

# Conditions

if [[ $# -ne 1 ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nHow to use:\n\n$0 <CN|SAMAccountName>\n"
  exit 1
fi

# Header

echo ""
echo "-------------------"
echo " ADS - AD Searcher "
echo "-------------------"

echo -e "\nResult:\n-------\n"

ldapsearch -x -h "${LDAP_HOST}" -D "${LDAP_BIND_USER}" -w "${LDAP_BIND_PASS}" -b "${LDAP_BASE_DN}" "cn=${NAME}*" | grep -e ^cn -e ^title -e ^telephoneNumber -e ^extensionAttribute1 -e ^extensionAttribute2 -e ^extensionAttribute3 -e ^extensionAttribute6 -e ^sAMAccountName -e ^mail: -e ^mobile | sed "s|^cn|Name|g" | sed "s|^title|Title|g" | sed "s|^telephoneNumber|Phone Number|g" | sed "s|^extensionAttribute1|Birth Date|g" | sed "s|^extensionAttribute2|Register|g" | sed "s|^extensionAttribute3|CPF|g" | sed "s|^extensionAttribute6|Join Us|g" | sed "s|^sAMAccountName|Account|g" | sed "s|^mail|Mail|g" | sed "s|mobile|Cellphone|g" | sed "/Cellphone/a Photo: http://brcpssps01:15439/User%20Photos/Imagens%20de%20Perfil/`echo '<ACCOUNT>'`_LThumb.jpg" | sed "s|^Name|\nName|g" | perl -MMIME::Base64 -MEncode=decode -n -00 -e 's/\n +//g;s/(?<=:: )(\S+)/decode("ISO-8859-1",decode_base64($1))/eg;print'

if [[ -z `ldapsearch -x -h "${LDAP_HOST}" -D "${LDAP_BIND_USER}" -w "${LDAP_BIND_PASS}" -b "${LDAP_BASE_DN}" "cn=${NAME}*" | grep -e ^cn -e ^title -e ^telephoneNumber -e ^extensionAttribute1 -e ^extensionAttribute2 -e ^extensionAttribute3 -e ^extensionAttribute6 -e ^sAMAccountName -e ^mail: -e ^mobile | sed "s|^cn|Name|g" | sed "s|^title|Title|g" | sed "s|^telephoneNumber|Phone Number|g" | sed "s|^extensionAttribute1|Birth Date|g" | sed "s|^extensionAttribute2|Register|g" | sed "s|^extensionAttribute3|CPF|g" | sed "s|^extensionAttribute6|Join Us|g" | sed "s|^sAMAccountName|Account|g" | sed "s|^mail|Mail|g" | sed "s|mobile|Cellphone|g" | grep "${NAME}"` ]]; then

  ldapsearch -x -h "${LDAP_HOST}" -D "${LDAP_BIND_USER}" -w "${LDAP_BIND_PASS}" -b "${LDAP_BASE_DN}" "sAMAccountName=${ACCOUNT}" | grep -e ^cn -e ^title -e ^telephoneNumber -e ^extensionAttribute1 -e ^extensionAttribute2 -e ^extensionAttribute3 -e ^extensionAttribute6 -e ^sAMAccountName -e ^mail: -e ^mobile | sed "s|^cn|Name|g" | sed "s|^title|Tittle|g" | sed "s|^telephoneNumber|Phone Number|g" | sed "s|^extensionAttribute1|Birth Date|g" | sed "s|^extensionAttribute2|Register|g" | sed "s|^extensionAttribute3|CPF|g" | sed "s|^extensionAttribute6|Join Us|g" | sed "s|^sAMAccountName|Account|g" | sed "s|^mail|Mail|g" | sed "s|mobile|Cellphone|g" | sed "/Cellphone/a Photo: http://brcpssps01:15439/User%20Photos/Imagens%20de%20Perfil/${ACCOUNT}_LThumb.jpg" | perl -MMIME::Base64 -MEncode=decode -n -00 -e 's/\n +//g;s/(?<=:: )(\S+)/decode("ISO-8859-1",decode_base64($1))/eg;print'

  if [[ -z `ldapsearch -x -h "${LDAP_HOST}" -D "${LDAP_BIND_USER}" -w "${LDAP_BIND_PASS}" -b "${LDAP_BASE_DN}" "sAMAccountName=${ACCOUNT}" | grep -e ^cn -e ^title -e ^telephoneNumber -e ^extensionAttribute1 -e ^extensionAttribute2 -e ^extensionAttribute3 -e ^extensionAttribute6 -e ^sAMAccountName -e ^mail: -e ^mobile | sed "s|^cn|Name|g" | sed "s|^title|Tittle|g" | sed "s|^telephoneNumber|Phone Number|g" | sed "s|^extensionAttribute1|Birth Date|g" | sed "s|^extensionAttribute2|Register|g" | sed "s|^extensionAttribute3|CPF|g" | sed "s|^extensionAttribute6|Join Us|g" | sed "s|^sAMAccountName|Account|g" | sed "s|^mail|Mail|g" | sed "s|mobile|Cellphone|g" | grep ${ACCOUNT}` ]]; then
    echo -e "Not found!"
  fi
fi

echo -e "\nScript finished.\n"
exit 0
