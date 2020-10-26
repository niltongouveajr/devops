#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Variables

GITLAB_URL="https://gitlab.local"
GITLAB_API_URL="${GITLAB_URL}/api/v4"
GITLAB_TOKEN="<token>"

# Conditions

if [[ ${EUID} -ne 0 ]]; then
  echo -e "\n[ Error ] This script must be run as root.\n"
  exit 1
fi

# Try access Gitlab via API
TRY_ACCESS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/groups"`

if [[ ! -z `echo "${TRY_ACCESS}" | grep "401 Unauthorized"` ]]; then
  echo -e "\n[ Error ] Cannot access ${GITLAB_API_URL}. Aborted.\n"
  exit 1
fi

# Run

echo ""
echo "---------------------"
echo " Gitlab Fix Branches "
echo "---------------------"
echo ""

GITLAB_PROJECT_PAGES=`curl --silent --head --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET ${GITLAB_API_URL}/projects | grep "^X-Total-Pages" | sed 's/[^0-9]*//g'`
COUNTER=1

if [[ $# -eq 0 ]]; then

  echo -n "You do not specify project id as parameter. Are you sure running for all projects? (Y/N): "
  read ALL_PROJECTS

  if [[ "${ALL_PROJECTS}" == "Y" ]] || [[ "${ALL_PROJECTS}" == "y" ]]; then

    echo ""
    while [ "${COUNTER}" -le "${GITLAB_PROJECT_PAGES}" ];do
      for GITLAB_PROJECT_ID in `curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects?page=${COUNTER}" | python -m json.tool  | egrep "http_url_to_repo|\"id\"" | sed "s|            .*||g" | egrep "\"id\"" | grep -o -E '[0-9]+'` ; do
        GITLAB_PROJECT_NAME=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
        GITLAB_LAST_COMMIT=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/commits/HEAD" | python -m json.tool | grep "created_at" | tail -n 1 | awk -F "\""  '{print $4}' | sed "s|\..*||g" | xargs -i date -d {} +"%d/%m/%Y - %H:%M:%S"`
        GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
        GITLAB_CHECK_BRANCH_QA_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
        GITLAB_CHECK_BRANCH_MAIN_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
        GITLAB_CHECK_BRANCH_MASTER_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/master" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`

        echo "Repository: ${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID}) (${GITLAB_LAST_COMMIT})"

        # Branch 'development' exists and is default

        if [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "true" ]]; then
          echo "            * Branch 'development' exists and is default."
          echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

        # Branch 'development' exists but is not default

        elif [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "false" ]]; then
          echo "            * Branch 'development' exists but is not default."
          echo "              - Setting branch 'development' as default"
          curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
          cho "              - Protecting branch 'development' (developers and maintainers can merge/push)"
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

        # Branch 'development' not exists

        elif [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "404 Branch Not Found" ]]; then
          echo "            * Branch 'development' not exists."
          if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
            echo "              - Creating branch 'development' (from 'master')"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=development&ref=master" >/dev/null
            echo "              - Setting branch 'development' as default"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
            echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
          elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
            echo "              - Creating branch 'development' (from 'main')"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=development&ref=main" >/dev/null
            echo "              - Setting branch 'development' as default"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
            echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
          else
            echo "              [ Error ] Cannot create branch 'development' with 'master' or 'main' source"
          fi
        fi

        # Branch 'qa' exists

        if [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "false" ]]; then
          echo "            * Branch 'qa' exists."
          echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

        # Branch 'qa' not exists

        elif [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "404 Branch Not Found" ]]; then
          echo "            * Branch 'qa' not exists."
          if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
            echo "              - Creating branch 'qa' (from 'master')"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=qa&ref=master" >/dev/null
            echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
          elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
            echo "              - Creating branch 'qa' (from 'main')"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=qa&ref=main" >/dev/null
            echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
          else
            echo "              [ Error ] Cannot create branch 'qa' with 'master' or 'main' source"
          fi
        fi

        # Branch 'main' exists

        if [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
          echo "            * Branch 'main' exists."
          echo "              - Protecting branch 'main' (developers can merge and maintainers can merge/push)"
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect" >/dev/null
          curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect?developers_can_push=false&developers_can_merge=true" >/dev/null

        # Branch 'main' not exists

        elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "404 Branch Not Found" ]]; then
          echo "            * Branch 'main' not exists."
          if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
            echo "              - Creating branch 'main' (from 'master')"
            curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=main&ref=master" >/dev/null
            echo "              - Protecting branch 'main' (developers can merge and maintainers can merge/push)"
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect" >/dev/null
            curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect?developers_can_push=false&developers_can_merge=true" >/dev/null
          else
            echo "              [ Error ] Cannot create branch 'main' with 'master' source"
          fi
        fi

        # Branch 'master' exists

        if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
          echo "            * Branch 'master' exists."
          echo "              - Protecting branch 'master' (read-only)"
          curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/protected_branches/master" >/dev/null
          curl --silent --insecure --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/protected_branches?name=master&push_access_level=0&merge_access_level=0" >/dev/null
          ##echo "- Deleting branch 'master'"
          ##curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/master" >/dev/null

        # Branch 'master' not exists

        elif [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "404 Branch Not Found" ]]; then
          echo "            * Branch 'master' not exists."
        fi
        echo ""
      done
      (( COUNTER++ ))
    done
    echo -e "\nCompleted!\n"

  else
    echo -e "\nAborted.\n"
    exit 0
  fi

elif [[ $# -eq 1 ]]; then

  GITLAB_PROJECT_ID=$1
  GITLAB_PROJECT_NAME=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}" | python -m json.tool | grep "http_url_to_repo" | awk -F "\"" '{print $4}'`
  GITLAB_LAST_COMMIT=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/commits/HEAD" | python -m json.tool | grep "created_at" | tail -n 1 | awk -F "\""  '{print $4}' | sed "s|\..*||g" | xargs -i date -d {} +"%d/%m/%Y - %H:%M:%S"`
  GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
  GITLAB_CHECK_BRANCH_QA_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
  GITLAB_CHECK_BRANCH_MAIN_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`
  GITLAB_CHECK_BRANCH_MASTER_EXISTS=`curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X GET "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/master" | python -m json.tool | grep -e "default" -e "404 Branch Not Found" | sed "s|.*: ||g" | sed "s|,||g" | sed "s|\"||g"`

  echo "Repository: ${GITLAB_PROJECT_NAME} (${GITLAB_PROJECT_ID}) (${GITLAB_LAST_COMMIT})"

  # Branch 'development' exists and is default

  if [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "true" ]]; then
    echo "            * Branch 'development' exists and is default."
    echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

  # Branch 'development' exists but is not default

  elif [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "false" ]]; then
    echo "            * Branch 'development' exists but is not default."
    echo "              - Setting branch 'development' as default"
    curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
    echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

  # Branch 'development' not exists

  elif [[ "${GITLAB_CHECK_BRANCH_DEVELOPMENT_EXISTS}" == "404 Branch Not Found" ]]; then
    echo "            * Branch 'development' not exists."
    if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
      echo "              - Creating branch 'development' (from 'master')"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=development&ref=master" >/dev/null
      echo "              - Setting branch 'development' as default"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
      echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
    elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
      echo "              - Creating branch 'development' (from 'main')"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=development&ref=main" >/dev/null
      echo "              - Setting branch 'development' as default"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X PUT "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}?default_branch=development" >/dev/null
      echo "              - Protecting branch 'development' (developers and maintainers can merge/push)"
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect" >/dev/null
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/development/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
    else
      echo "              [ Error ] Cannot create branch 'development' with 'master' or 'main' source"
    fi
  fi

  # Branch 'qa' exists

  if [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "false" ]]; then
    echo "            * Branch 'qa'  exists."
    echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null

  # Branch 'qa' not exists

  elif [[ "${GITLAB_CHECK_BRANCH_QA_EXISTS}" == "404 Branch Not Found" ]]; then
    echo "            * Branch 'qa' not exists."
    if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
      echo "              - Creating branch 'qa' (from 'master')"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=qa&ref=master" >/dev/null
      echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
    elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
      echo "              - Creating branch 'qa' (from 'main')"
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=qa&ref=main" >/dev/null
      echo "              - Protecting branch 'qa' (developers and maintainers can merge/push)"
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect" >/dev/null
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/qa/protect?developers_can_push=true&developers_can_merge=true" >/dev/null
    else
      echo "              [ Error ] Cannot create branch 'qa' with 'master' or 'main' source"
    fi
  fi

  # Branch 'main' exists

  if [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "false" ]]; then
    echo "            * Branch 'main' exists."
    echo "              - Protecting branch 'main' (developers can merge and maintainers can merge/push)"
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect" >/dev/null
    curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect?developers_can_push=false&developers_can_merge=true" >/dev/null

  # Branch 'main' not exists

  elif [[ "${GITLAB_CHECK_BRANCH_MAIN_EXISTS}" == "404 Branch Not Found" ]]; then
    echo "            * Branch 'main' not exists."
    echo "              - Creating branch 'main' (from 'master')"
    if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
      curl --silent --insecure --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" -X POST "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches?branch=main&ref=master" >/dev/null
      echo "              - Protecting branch 'main' (developers can merge and maintainers can merge/push)"
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect" >/dev/null
      curl --silent --insecure --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/main/protect?developers_can_push=false&developers_can_merge=true" >/dev/null
    else
      echo "              [ Error ] Cannot create branch 'main' with 'master' source"
    fi
  fi

  # Branch 'master' exists

  if [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "true" ]] || [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "false" ]]; then
    echo "            * Branch 'master' exists."
    echo "              - Protecting branch 'master' (read-only)"
    curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/protected_branches/master" >/dev/null
    curl --silent --insecure --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/protected_branches?name=master&push_access_level=0&merge_access_level=0" >/dev/null
    ##echo "- Deleting branch 'master'"
    ##curl --silent --insecure --request DELETE --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/repository/branches/master" >/dev/null

  # Branch 'master' not exists

  elif [[ "${GITLAB_CHECK_BRANCH_MASTER_EXISTS}" == "404 Branch Not Found" ]]; then
    echo "            * Branch 'master' not exists."
  fi

  echo -e "\nCompleted!\n"

else 

  echo -e "[ Error ] Invalid number of parameter. Usage: $0 <project-id>\n"
  exit 1

fi

