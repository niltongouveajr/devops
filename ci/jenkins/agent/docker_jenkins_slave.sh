#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

DOCKER_IMAGE_VERSION="1.0"
DOCKER_IMAGE_NAME="docker.domain.local/devops/jenkins/agent:${DOCKER_IMAGE_VERSION}"
DOCKER_VOLUMES="-v /var/run/docker.sock:/var/run/docker.sock -v /srv/config:/srv/config:ro"

# Conditions

if [[ "$#" -ne "1" ]]; then
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <build|run|exec|runexec|push>\n"
  exit 1
fi

# Run

if [[ "$1" == "build" ]]; then
  docker build -t ${DOCKER_IMAGE_NAME} .
  exit 0
elif [[ "$1" == "run" ]]; then
  docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $1}' | xargs docker rm -f 2>/dev/null ; docker run ${DOCKER_VOLUMES} -d ${DOCKER_IMAGE_NAME}
  exit 0
elif [[ "$1" == "exec" ]]; then
  DOCKER_IMAGE_HASH="$(docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $1}' | head -n 1)"
  docker exec -it ${DOCKER_IMAGE_HASH} /bin/bash
  exit 0
elif [[ "$1" == "runexec" ]]; then
  docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $1}' | xargs docker rm -f 2>/dev/null ; docker run ${DOCKER_VOLUMES} -d ${DOCKER_IMAGE_NAME}
  DOCKER_IMAGE_HASH="$(docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $1}' | head -n 1)"
  docker exec -it ${DOCKER_IMAGE_HASH} /bin/bash
  exit 0
elif [[ "$1" == "push" ]]; then
  docker push ${DOCKER_IMAGE_NAME}
  exit 0
else
  echo -e "\n[ Error ] Invalid parameter.\n\nUsage: $0 <build|exec|run>\n\n"
  exit 1
fi
