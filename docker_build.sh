#!/bin/bash

DOCKER_BIN=`which docker`
DOCKER_FILE=./Dockerfile
FORWARD_PORTS="8081:8081"
CONTAINER_NAME="$1"
PRE_REQ_CMD=`cd server && npm install`

if [[ "${CONTAINER_NAME}" == "" ]];
then
  echo -e "USAGE: $0 <CONTAINER NAME>"
  exit 1
fi

if [[ "$?" != "0" ]];
then
  echo -e "ERROR: Docker isn't installed OR PATH is set incorrectly"
  exit 1
fi

if "${PRE_REQ_CMD}" != "" ]];
then
  echo -e "INFO: Running pre req command: ${PRE_REQ_CMD}"
  ${PRE_REQ_CMD}
  if [[ "${?}" != "0" ]];
  then
    echo -e "FATAL: ${PRE_REQ_CMD} returned non-zero status code!"
    exit 1
  else
    echo -e "INFO: Done running pre req command"
  fi
fi

CONTAINER_EXISTS=`${DOCKER_BIN} ps -a | grep -v "CONTAINER ID" | grep "${CONTAINER_NAME}" | wc -l | awk '{print $1}'`
if [[ "${CONTAINER_EXISTS}" == "1" ]];
then
  CONTAINER_ID=`${DOCKER_BIN} ps -a | grep "${CONTAINER_NAME}" | awk '{print $1}'`
  IMAGE_ID=`${DOCKER_BIN} ps -a | grep "${CONTAINER_NAME}" | awk '{print $2}'`
  echo -e "INFO: Found an existing container ..."
  echo -e "`${DOCKER_BIN} ps -a | grep ${CONTAINER_NAME}`"
  echo -e "INFO: Stopping container ${CONTAINER_ID} ..."
  ${DOCKER_BIN} stop ${CONTAINER_ID}
  if [[ "$?" != "0" ]];
  then
    echo -e "ERROR: Failed to stop container ${CONTAINER_ID}"
    exit 1
  fi
  echo -e "INFO: Removing container ${CONTAINER_ID} ..."
  ${DOCKER_BIN} rm ${CONTAINER_ID}
  if [[ "$?" != "0" ]];
  then
    echo -e "ERROR: Failed to remove container ${CONTAINER_ID}"
    exit 1
  fi 
  echo -e "INFO: Removing existing image ${IMAGE_ID} ..."
  echo -e "`${DOCKER_BIN} images | grep ${IMAGE_ID}`"
  ${DOCKER_BIN} rmi ${IMAGE_ID}
  if [[ "$?" != "0" ]];
  then
    echo -e "ERROR: Failed to remove image ${IMAGE_ID}"
    exit 1
  fi
else
  if [[ "${CONTAINER_EXISTS}" != "0" ]];
  then
    echo -e "ERROR: Multiple containers exist with name ${CONTAINER_NAME}"
    exit 1
  fi
fi

# Build the image
if [[ ! -f "${DOCKER_FILE}" ]];
then
  echo -e "ERROR: Unable to find Dockerfile"
  exit 1
else
  echo -e "INFO: Building Docker image..."
  DOCKER_IMAGE_ID=`${DOCKER_BIN} build . | tail -1 | awk '{print $3}'` 
  if [[ "$?" == "0" ]];
  then
    echo -e "INFO: Starting container ..."
    NEW_CONTAINER_ID=`${DOCKER_BIN} run -d --name ${CONTAINER_NAME} -p ${FORWARD_PORTS} ${DOCKER_IMAGE_ID}`
    if [[ "$?" == "0" ]];
    then
      echo -e "INFO: The container has started"
      echo -e "`${DOCKER_BIN} ps -a | grep ${CONTAINER_NAME}`"
      exit 0
    else
      echo -e "ERROR: Failed to create new container called ${CONTAINER_NAME} using image ${DOCKER_IMAGE_ID}"
      exit 1
    fi
  fi
fi
