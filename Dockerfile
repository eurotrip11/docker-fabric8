FROM debian:stable

#ENV http_proxy=http://192.168.21.28:3128
RUN apt-get update && apt-get install -y --no-install-recommends procps openjdk-7-jre-headless tar curl && apt-get autoremove -y && apt-get clean

ENV FABRIC8_REPO_URL http://repo.fusesource.com/nexus/content/groups/public
#ENV FABRIC8_REPO_URL https://repo1.maven.org/maven2
#ENV FABRIC8_DISTRO_VERSION 1.0.0.redhat-379
ENV FABRIC8_DISTRO_VERSION 1.2.0.redhat-128	
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
#ENV FABRIC8_PUBLIC_HOSTNAME fabric8.dev
#ENV FABRIC8_GLOBAL_RESOLVER publichostname
ENV FABRIC8_RUNTIME_ID root
ENV FABRIC8_KARAF_NAME root
ENV FABRIC8_BINDADDRESS 0.0.0.0
#ENV FABRIC8_PROFILES docker
ENV FABRIC8_HTTP_PORT 8181
ENV FABRIC8_HTTP_PROXY_PORT 8181

# create the fabric8 user and group
RUN groupadd -r fabric8 -g 433 && useradd -u 431 -r -g fabric8 -d /opt/fabric8 -s /sbin/nologin -c "fabric8 user" fabric8

RUN mkdir /opt/fabric8-karaf-$FABRIC8_DISTRO_VERSION

RUN cd /opt && curl $FABRIC8_REPO_URL/io/fabric8/fabric8-karaf/$FABRIC8_DISTRO_VERSION/fabric8-karaf-$FABRIC8_DISTRO_VERSION.tar.gz | \
  tar zx && chown -R fabric8:fabric8 /opt/fabric8-karaf-$FABRIC8_DISTRO_VERSION

# Make sure the distribution is available from a well-known place
RUN ln -s /opt/fabric8-karaf-$FABRIC8_DISTRO_VERSION /opt/fabric8 && chown -R fabric8:fabric8 /opt/fabric8

#ADD startup.sh /opt/fabric8/startup.sh

RUN chown -R fabric8:fabric8 /opt/fabric8 /opt/fabric8-karaf-$FABRIC8_DISTRO_VERSION /opt/fabric8-karaf-$FABRIC8_DISTRO_VERSION/*

# TODO we have an issue with permissions and ownership on boot2docker:
# https://github.com/boot2docker/boot2docker/issues/527
# so for now lets just run as root
#USER fabric8

# lets remove the karaf.name by default so we can default it from env vars
RUN sed -i '/karaf.name=root/d' /opt/fabric8/etc/system.properties 
RUN sed -i '/runtime.id=/d' /opt/fabric8/etc/system.properties 

ENV ADMIN_USERNAME=admin
ENV ADMIN_PASSWORD=admin

RUN echo "\nbind.address=0.0.0.0" >> /opt/fabric8/etc/system.properties
#RUN echo "\npublichostname=$FABRIC8_PUBLIC_HOSTNAME" >> /opt/fabric8/etc/system.properties
#RUN cat /opt/fabric8/etc/system.properties | grep -v 'local.resolver=' | grep -v 'global.resolver=' > /opt/fabric8/etc/system.properties.tmp
#RUN mv /opt/fabric8/etc/system.properties.tmp etc/system.properties
#RUN echo "\nlocal.resolver=$FABRIC8_GLOBAL_RESOLVER" >> /opt/fabric8/etc/system.properties
#RUN echo "\nglobal.resolver=$FABRIC8_GLOBAL_RESOLVER" >> /opt/fabric8/etc/system.properties
#RUN echo fabric.environment=docker >> /opt/fabric8/etc/system.properties
RUN echo zookeeper.password.encode=true >> /opt/fabric8/etc/system.properties
RUN echo "\nadmin=$ADMIN_USERNAME,$ADMIN_PASSWORD" >> /opt/fabric8/etc/users.properties
#RUN echo "admin=${ADMIN_USERNAME},${ADMIN_PASSWORD}" >> /opt/fabric8/etc/users.properties

# lets remove the karaf.delay.console=true to disable the progress bar
RUN sed -i 's/karaf.delay.console=true/karaf.delay.console=false/' /opt/fabric8/etc/config.properties 

# lets enable logging to standard out
RUN sed -i 's/log4j.rootLogger=INFO, out, osgi:*/log4j.rootLogger=INFO, stdout, osgi:*/' /opt/fabric8/etc/org.ops4j.pax.logging.cfg

# default values of environment variables supplied by default for child containers created by fabric8
# which have sensible defaults for folks creating new fabrics but can be overloaded when using docker run

#ENV DOCKER_HOST http://172.17.42.1:4243
#ENV DOCKER_HOST http://192.168.59.103:2375

EXPOSE 1099 2181 8101 8181 9300 9301 44444 61616

# lets default to the fabric8 dir so folks can more easily navigate to the data/logs
WORKDIR /opt/fabric8

RUN echo "\nkaraf.name=$FABRIC8_KARAF_NAME" >> /opt/fabric8/etc/system.properties
RUN echo "\nruntime.id=$FABRIC8_RUNTIME_ID" >> /opt/fabric8/etc/system.properties

CMD /opt/fabric8/bin/karaf server