#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

if [[ $# -eq 1 ]]; then
  KUBERNETES_NODES=$1
  if [[ -z `kubectl get nodes | awk '{print $1}' | grep -v "NAME" | grep "${KUBERNETES_NODES}"` ]]; then
    echo -e "\n[ Error ] Node '${KUBERNETES_NODES}' not exists.\n"
    exit 1
  fi
elif [[ $# -eq 0 ]]; then
  KUBERNETES_NODES="$(kubectl get nodes | awk '{print $1}' | grep -v "NAME")"
else
  echo -e "\n[ Error ] Invalid number of parameters.\n\nUsage: $0 <node>\n"
  exit 1
fi

# Run

for NODE in `echo -e "${KUBERNETES_NODES}"` ; do

  KUBERNETES_PODS_AND_NAMESPACES="$(kubectl get pods --all-namespaces -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace --field-selector spec.nodeName=${NODE} | egrep "development|qa|production")"

  echo ""
  echo "--------------------"
  echo " Node: ${NODE} "
  echo "--------------------"
  echo ""
 
  while IFS= read -r RESOURCE ; do
    POD=`echo -e "${RESOURCE}" | awk '{print $1}'`
    NAMESPACE=`echo -e "${RESOURCE}" | awk '{print $2}'`
    TOP_POD="$(kubectl top pod "${POD}" -n "${NAMESPACE}" --containers | grep -v POD | awk '{print $1}')"
    TOP_NAME="$(kubectl top pod "${POD}" -n "${NAMESPACE}" --containers | grep -v POD | awk '{print $2}')"
    TOP_CPU="$(kubectl top pod "${POD}" -n "${NAMESPACE}" --containers | grep -v POD | awk '{print $3}')"
    TOP_MEMORY="$(kubectl top pod "${POD}" -n "${NAMESPACE}" --containers | grep -v POD | awk '{print $4}')"
    if [[ ! -z "${TOP_NAME}" ]]; then
      echo "Namespace: ${NAMESPACE}"
      echo "Name:      ${TOP_NAME}"
      echo "CPU:       ${TOP_CPU}"
      echo "Memory:    ${TOP_MEMORY}"
      echo ""
    fi
  done <<< "${KUBERNETES_PODS_AND_NAMESPACES}"

done
