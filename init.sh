#!/bin/sh

# Example Docker entrypoint for a nodejs app

MAX_OLD_SPACE=256
NODE_ENTRY=myapp.js
WORKDIR=/src

if [[ -d "${WORKDIR}" ]];
then
  cd ${WORKDIR} && node --max_old_space_size=${MAX_OLD_SPACE} ${NODE_ENTRY}
  if [[ "$?" == "1" ]];
  then
    echo -e "FATAL: ${NODE_ENTRY} failed to launch"
    exit 1
  fi
else
  echo -e "FATAL: ${WORKDIR} does not exist"
  exit 1
fi
