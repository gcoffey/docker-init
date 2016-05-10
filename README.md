# docker-init
Build a docker image &amp; run a container

Simply create your Dockerfile in the same directory as docker_build.sh

you can change the following variables in docker_build.sh to suit your requirement

DOCKER_FILE=./Dockerfile
FORWARD_PORTS="8081:8081"
PRE_REQ_CMD=`a command to run before building the container`

then run...

./docker_build.sh my-container-name

the next time you run the above, the container, and docker image, will be removed and rebuilt
