#!/bin/bash
#clear

# Author: Nilton R Gouvea Junior

# Run

#service snmpd restart
snmptranslate -On NET-SNMP-EXTEND-MIB::nsExtendOutput1Line.\"$1\" | xargs snmpwalk -On -v2c -c zabbix 127.0.0.1
