#!/usr/bin/env bash

echo "Starting the fabric8 container"
docker pull sonatype/nexus:oss
docker run -d -p 8081:8081 --name nexus sonatype/nexus:oss
docker run -p 8101:8101 -p 8181:8181 -d -t --link nexus:nexus --name fabric8 -e DOCKER_HOST=http://192.168.59.103:2375 eurotrip:fabric8
#docker port fabric8demo 8181
#docker port fabric8demo 8101