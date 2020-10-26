#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Usage: su - jenkins -c /jenkins_startup.sh <instance> <start|restart|status|stop>
# Start on boot: Put in /etc/rc.local: su jenkins -c "/var/lib/jenkins/scripts/jenkins-startup.sh <instance> <start|restart|status|stop>"

# Variables

export JAVA="/opt/tools/java8/bin/java"
export JENKINS_DIR="/var/lib/jenkins"
export JENKINS_USER="jenkins" 
export JENKINS_INSTANCE="$1"
export JENKINS_INSTANCE_VALIDATION="instance"
export JENKINS_WAR_VERSION_DEFAULT="v2.249.2"

# Conditions for execution

if [ "$USER" != "${JENKINS_USER}" ]; then
  echo -e "\n[Error] This script must be run by '${JENKINS_USER}' user.\n"
  exit 1
fi

if [ $# -ne "2" ]; then
  echo -e "\nUsage:\n\n$0 <${JENKINS_INSTANCE_VALIDATION}> <start|restart|status|stop>\n"
  exit 1
fi

if [[ $1 != `echo ${JENKINS_INSTANCE_VALIDATION} | sed "s|\||\n|g" | grep ${JENKINS_INSTANCE}` ]]; then
  echo -e "\nUsage:\n\n$0 <${JENKINS_INSTANCE_VALIDATION}> <start|restart|status|stop>\n\n[Error] The instance '${JENKINS_INSTANCE}' is not valid.\n" exit 1
fi

# Variables customization for instances

function instance(){
case "${JENKINS_INSTANCE}" in
# For Java > 1.8 use -XX:MaxMetaspaceSize. For Java < 1.8 -XX:MaxPermSize
  all)
    sleep 0
  ;;
  vnt)
    export JENKINS_HOME="${JENKINS_DIR}/instances/${JENKINS_INSTANCE}"
    export JENKINS_WAR_VERSION="${JENKINS_WAR_VERSION_DEFAULT}"
    export JENKINS_WAR_FILE="${JENKINS_DIR}/app/jenkins-${JENKINS_WAR_VERSION}.war"
    export JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
    export JENKINS_PORT=8080 # Default: 8080
    export JENKINS_ARGS="--daemon --httpPort=${JENKINS_PORT} --logfile=${JENKINS_HOME}/log/${JENKINS_INSTANCE}.log --sessionTimeout=1440 --sessionEviction=43200"
    #export JENKINS_JAVA_OPTIONS="-Xmx2048m -Djava.awt.headless=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Sao_Paulo -Duser.timezone=America/Sao_Paulo -Dhudson.model.ParametersAction.safeParameters=true -Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dhudson.plugins.parameterizedtrigger.ProjectSpecificParametersActionFactory.compatibility_mode=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true -Dhudson.model.DirectoryBrowserSupport.CSP= -DsessionTimeout=1440 -DsessionEviction=43200 -XX:ErrorFile=${JENKINS_HOME}/${JENKINS_INSTANCE}_error.log"
    export JENKINS_JAVA_OPTIONS="
-Xmx4096m
-Xms2048m
-Djava.awt.headless=true
-Duser.timezone=America/Sao_Paulo
-Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Sao_Paulo
-Dhudson.model.DirectoryBrowserSupport.CSP=
-Dhudson.model.ParametersAction.safeParameters=true
-Dhudson.model.ParametersAction.keepUndefinedParameters=true
-Dhudson.plugins.parameterizedtrigger.ProjectSpecificParametersActionFactory.compatibility_mode=true
-Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true
-DsessionTimeout=1440
-DsessionEviction=43200
-XX:+UseCompressedOops
-XX:+AlwaysPreTouch
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=
-verbose:gc
-Xloggc:${JENKINS_HOME}/log/gc-%t.log
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=20m
-XX:+UseGCLogFileRotation
-XX:+PrintGC
-XX:+PrintGCTimeStamps
-XX:+PrintGCDateStamps
-XX:+PrintGCDetails
-XX:+PrintGCCause
-XX:+PrintHeapAtGC
-XX:+PrintTenuringDistribution
-XX:+PrintReferenceGC
-XX:+PrintAdaptiveSizePolicy
-XX:+PrintFlagsFinal
-XX:+UnlockDiagnosticVMOptions
-XX:+LogVMOutput
-XX:LogFile=${JENKINS_HOME}/log/jvm.log
-XX:+UseG1GC
-XX:+UseStringDeduplication
-XX:+ParallelRefProcEnabled
-XX:+DisableExplicitGC
-XX:+UnlockDiagnosticVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:ErrorFile=${JENKINS_HOME}/log/${JENKINS_INSTANCE}_error.log"
  ;;

  old)
    export JENKINS_HOME="${JENKINS_DIR}/instances/${JENKINS_INSTANCE}"
    export JENKINS_WAR_VERSION="${JENKINS_WAR_VERSION_DEFAULT}"
    export JENKINS_WAR_FILE="${JENKINS_DIR}/app/jenkins-${JENKINS_WAR_VERSION}.war"
    export JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
    export JENKINS_PORT=8081 # Default: 8081
    export JENKINS_ARGS="--daemon --httpPort=${JENKINS_PORT} --logfile=${JENKINS_HOME}/${JENKINS_INSTANCE}.log --sessionTimeout=1440 --sessionEviction=43200"
#    export JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Dhudson.model.ParametersAction.safeParameters=true -Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dhudson.plugins.parameterizedtrigger.ProjectSpecificParametersActionFactory.compatibility_mode=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true -Dhudson.model.DirectoryBrowserSupport.CSP= -DsessionTimeout=1440 -DsessionEviction=43200 -XX:ErrorFile=${JENKINS_HOME}/${JENKINS_INSTANCE}_error.log"
    export JENKINS_JAVA_OPTIONS="
-Xmx2048m
-Xms1024m
-Djava.awt.headless=true
-Duser.timezone=America/Sao_Paulo
-Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Sao_Paulo
-Dhudson.model.DirectoryBrowserSupport.CSP=
-Dhudson.model.ParametersAction.safeParameters=true
-Dhudson.model.ParametersAction.keepUndefinedParameters=true
-Dhudson.plugins.parameterizedtrigger.ProjectSpecificParametersActionFactory.compatibility_mode=true
-Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true
-DsessionTimeout=1440
-DsessionEviction=43200
-XX:+UseCompressedOops
-XX:+AlwaysPreTouch
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=
-verbose:gc
-Xloggc:${JENKINS_HOME}/log/gc-%t.log
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=20m
-XX:+UseGCLogFileRotation
-XX:+PrintGC
-XX:+PrintGCTimeStamps
-XX:+PrintGCDateStamps
-XX:+PrintGCDetails
-XX:+PrintGCCause
-XX:+PrintHeapAtGC
-XX:+PrintTenuringDistribution
-XX:+PrintReferenceGC
-XX:+PrintAdaptiveSizePolicy
-XX:+PrintFlagsFinal
-XX:+UnlockDiagnosticVMOptions
-XX:+LogVMOutput
-XX:LogFile=${JENKINS_HOME}/log/jvm.log
-XX:+UseG1GC
-XX:+UseStringDeduplication
-XX:+ParallelRefProcEnabled
-XX:+DisableExplicitGC
-XX:+UnlockDiagnosticVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:ErrorFile=${JENKINS_HOME}/log/${JENKINS_INSTANCE}_error.log"
  ;;
  *)
    usage "Unknown instance"
  ;;
esac
}

instance

# Conditions for execution

if [ ! -d "${JENKINS_HOME}" ] && [ "${JENKINS_INSTANCE}" != "all" ]; then
  echo -e "\nUsage:\n\n$0 <${JENKINS_INSTANCE_VALIDATION}> <start|restart|status|stop>\n\n[Error] Cannot find JENKINS_HOME directory for [ ${JENKINS_INSTANCE} ] instance.\n"
  exit 1
fi

if [ "${JENKINS_INSTANCE}" == "all" ]; then
  for INSTANCE in `echo ${JENKINS_INSTANCE_VALIDATION} | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do  
    if [ ! -d ${JENKINS_DIR}/instances/${INSTANCE} ]; then
      echo -e "\nUsage:\n\n$0 <${JENKINS_INSTANCE_VALIDATION}> <start|restart|status|stop>\n\n[Error] Cannot find JENKINS_HOME directory for [ ${INSTANCE} ] instance.\n"
      exit 1
    fi
  done
fi

# Common Arguments:

# httpPort
# httpListenAddress
# httpsPort
# httpsListenAddress
# prefix
# ajp13Port
# ajp13ListenAddress
# argumentsRealm.passwd.$ADMIN_USER
# argumentsRealm.roles.$ADMIN_USER=admin
# logfile

echo ""
echo "---------------------------------"
echo " Jenkins - Continuos Integration "
echo "---------------------------------"

function start(){
  if [ "${JENKINS_INSTANCE}" == "all" ]; then
    echo -e "\nStarting all Jenkins for instances...\n"
    for STATUS in `echo $JENKINS_INSTANCE_VALIDATION | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do
      sleep 2
      JENKINS_INSTANCE=${STATUS}
      JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
      instance
      if [ -z "${JENKINS_PROCESS}" ]; then
        echo -e "Starting Jenkins for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}..."
        sleep 2
        JENKINS_HOME=${JENKINS_HOME} ${JAVA} ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_WAR_FILE} ${JENKINS_ARGS}
      else
        echo -e "Jenkins already running for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}."
      fi
    done
    echo ""
  else
    if [ -z "${JENKINS_PROCESS}" ]; then
      echo -e "\nStarting Jenkins for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}...\n"
      sleep 2
      JENKINS_HOME=${JENKINS_HOME} ${JAVA} ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_WAR_FILE} ${JENKINS_ARGS}
      echo ""
    else
      echo -e "\nJenkins already running for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}.\n"
      exit 1
    fi
  fi
}

function restart(){
  if [ "${JENKINS_INSTANCE}" == "all" ]; then
    echo -e "\nRestarting all Jenkins instances...\n"
    ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} login --username 'vntprojhud' --password 'dEv0p$vNt' 2>/dev/null
    for STATUS in `echo $JENKINS_INSTANCE_VALIDATION | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do
      sleep 2
      JENKINS_INSTANCE=${STATUS}
      JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
      echo -e "Restarting [ ${JENKINS_INSTANCE} ]"
      ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} safe-shutdown 2>/dev/null
      echo ${JENKINS_PROCESS} | xargs kill -9 2>/dev/null >/dev/null
      for STATUS in `echo $JENKINS_INSTANCE_VALIDATION | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do
        sleep 2
        JENKINS_INSTANCE=${STATUS}
        JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
        instance
        if [ -z "${JENKINS_PROCESS}" ]; then
          JENKINS_HOME=${JENKINS_HOME} ${JAVA} ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_WAR_FILE} ${JENKINS_ARGS}
        fi
      done
      echo ""   
    done
    ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} logout 2>/dev/null
  else
    if [ ! -z "${JENKINS_PROCESS}" ]; then
      echo -e "\nRestarting Jenkins for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}...\n"
      sleep 2
      ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} login --username 'vntprojhud' --password 'dEv0p$vNt' 2>/dev/null
      ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} safe-shutdown 2>/dev/null
      echo ${JENKINS_PROCESS} | xargs kill -9 2>/dev/null >/dev/null
      ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} logout 2>/dev/null
      JENKINS_HOME=${JENKINS_HOME} ${JAVA} ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_WAR_FILE} ${JENKINS_ARGS}
      echo ""
    else
      echo -e "\nRestarting Jenkins for instance [ ${JENKINS_INSTANCE} ] on port ${JENKINS_PORT}...\n"
      sleep 2
      JENKINS_HOME=${JENKINS_HOME} ${JAVA} ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_WAR_FILE} ${JENKINS_ARGS}
      echo ""
    fi
  fi
}

function status(){
  if [ "${JENKINS_INSTANCE}" == "all" ]; then
    echo ""
    for STATUS in `echo $JENKINS_INSTANCE_VALIDATION | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do
      JENKINS_INSTANCE=${STATUS}
      JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
      if [ -z "${JENKINS_PROCESS}" ]; then
        echo -e "Jenkins is NOT running for instance [ ${JENKINS_INSTANCE} ]"
      else
        echo -e "Jenkins is running for instance [ ${JENKINS_INSTANCE} ]"
      fi
    done
    echo ""
  else
    if [ -z "${JENKINS_PROCESS}" ]; then
      echo -e "\nJenkins is NOT running for instance [ ${JENKINS_INSTANCE} ]\n"
    else
      echo -e "\nJenkins is running for instance [ ${JENKINS_INSTANCE} ]\n"
    fi
  fi
}

function stop(){
  if [ "${JENKINS_INSTANCE}" == "all" ]; then
    echo -e "\nStoping all Jenkins instances...\n"
    ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} login --username 'vntprojhud' --password 'dEv0p$vNt' 2>/dev/null
    for STATUS in `echo $JENKINS_INSTANCE_VALIDATION | sed "s|all||g" | sed "s|\||\n|g" | grep -v "^$"` ; do
      sleep 2
      JENKINS_INSTANCE=${STATUS}
      JENKINS_PROCESS=$(ps -ef | grep "${JENKINS_WAR_FILE}" | grep "\/instances\/${JENKINS_INSTANCE}" | awk '{print $2}')
      echo -e "Stoping [ ${JENKINS_INSTANCE} ]"
      ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} safe-shutdown 2>/dev/null
      echo ${JENKINS_PROCESS} | xargs kill -9 2>/dev/null >/dev/null
    done
    ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} logout 2>/dev/null
    echo ""
  else
    if [ ! -z "${JENKINS_PROCESS}" ]; then
      echo -e "\nStoping Jenkins for instance [ ${JENKINS_INSTANCE} ]\n"
        sleep 2
        ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} login --username 'vntprojhud' --password 'dEv0p$vNt' 2>/dev/null
        ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} safe-shutdown 2>/dev/null
        echo ${JENKINS_PROCESS} | xargs kill -9 2>/dev/null >/dev/null
        ${JAVA} -jar ${JENKINS_DIR}/app/jenkins-cli.jar -s http://localhost/${JENKINS_INSTANCE} logout 2>/dev/null
    else
      echo -e "\nJenkins is NOT running for instance [ ${JENKINS_INSTANCE} ]\n"
      exit 1
    fi
  fi
}

function usage (){
  echo "$2"
  exit 1
}

case "$2" in
  start)
    start
  ;;
  restart)
    restart
  ;;
  status)
    status
  ;;
  stop)
    stop
  ;;
  *)
    echo -e "\nUsage:\n\n$0 <${JENKINS_INSTANCE_VALIDATION}> <start|restart|status|stop>\n"
    exit 1
  ;;
esac

echo "Complete!"
echo ""
exit 0
