#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

DATABASE_PATH="/srv/rancher/database"

# Conditions

if [ $# -ne 1 ]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUse: $0 <start/stop/restart>\n"
  exit 1
fi

# Run

if [[ $1 == "start" ]] || [[ $1 == "restart" ]]; then
  docker ps -a | grep rancher | awk '{print $1}' | xargs docker stop 2>/dev/null | xargs docker rm -f 2>/dev/null
  sleep 2
  docker run --name rancher -d -v /srv/rancher/volume:/var/lib/rancher -v /srv/rancher/ssl/cacerts.pem:/etc/rancher/ssl/cacerts.pem -v /srv/rancher/ssl/key.pem:/etc/rancher/ssl/key.pem -v /srv/rancher/ssl/cert.pem:/etc/rancher/ssl/cert.pem --restart=unless-stopped -p 443:443 rancher/rancher:v2.2.2


  sleep 2
  echo -e "\nRancher started.\n"
elif [ $1 == "stop" ]; then
  docker ps -a | grep rancher | awk '{print $1}' | xargs docker stop 2>/dev/null | xargs docker rm -f 2>/dev/null
  sleep 2
  echo -e "\nRancher stopped.\n"
else
  echo -e "\n[ Error ] Unknown parameter.\n\nUse: $0 <start/stop>\n"
  exit 1
fi

# Enable API Auditing:

#-e AUDIT_LEVEL=1 \
#-e AUDIT_LOG_PATH=/var/log/auditlog/rancher-api-audit.log \
#-e AUDIT_LOG_MAXAGE=20 \
#-e AUDIT_LOG_MAXBACKUP=20 \
#-e AUDIT_LOG_MAXSIZE=100 \
