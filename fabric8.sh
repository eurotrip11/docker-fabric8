#!/usr/bin/env bash

echo "Starting the fabric8 container"
docker run -p 8101:8101 -p 8181:8181 -d -t --name fabric8demo -e DOCKER_HOST=http://192.168.59.103:2375 eurotrip:fabric8
#docker port fabric8demo 8181
#docker port fabric8demo 8101