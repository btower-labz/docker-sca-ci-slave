# Basic sca ci agent image.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run

FROM openjdk:8-jdk
MAINTAINER BTower Labz <labz@btower.net>

ENV HOME /home/jenkins
ENV SWARM_DESCRIPTION "sca swarm agent"

ARG LABELS=/home/jenkins/swarm-labels.cfg

RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
LABEL Description="Provides basic sca ci agent, either slave or swarm mode" Vendor="BTower" Version="1.0"

ARG SLAVE_VERSION=3.9
ARG SWARM_VERSION=3.4
ARG JAR_PATH=/usr/share/jenkins
ARG SRC_PATH=/usr/local/src
ARG SWARM_REPO=https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client
ARG SLAVE_REPO=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting

USER root
RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update && apt-get install -y curl git unzip lsof nano wget curl
RUN apt-get update && apt-get install -y ant ant-doc ant-optional ant-contrib
RUN apt-get update && apt-get install -y maven maven-ant-helper

# Install agent script
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod ugo+x /usr/local/bin/jenkins-agent

# Install slave
# TODO: get rid of double load
RUN curl --create-dirs -sSLo ${JAR_PATH}/slave.jar ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.jar \
  && chmod 755 ${JAR_PATH} \
  && chmod 644 ${JAR_PATH}/slave.jar
# Save slave source jar and docs
RUN mkdir -p ${SRC_PATH}/slave
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.jar
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.jar.md5
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}-sources.jar
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}-sources.jar.md5
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}-tests.jar
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}-tests.jar.md5
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.pom
RUN cd ${SRC_PATH}/slave && wget ${SLAVE_REPO}/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.pom.md5

# Install swarm
# TODO: get rid of double load
RUN curl --create-dirs -sSLo ${JAR_PATH}/swarm.jar ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar \
  && chmod 755 ${JAR_PATH} \
  && chmod 644 ${JAR_PATH}/swarm.jar
# Save swarm source jar and docs
RUN mkdir -p ${SRC_PATH}/swarm
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar.md5
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-javadoc.jar
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-javadoc.jar.md5
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-sources.jar
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-sources.jar.md5
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.pom
RUN cd ${SRC_PATH}/swarm && wget ${SWARM_REPO}/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.pom.md5

# Set initial labels
RUN touch ${LABELS}
RUN printf " sca" >>${LABELS}
RUN printf " ant" >>${LABELS}
RUN printf " maven" >>${LABELS}
RUN chown jenkins:jenkins ${LABELS}
RUN ls -la ${LABELS}

USER jenkins
RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

# Show info in build log
RUN uname -a
RUN cat /etc/issue
RUN cat ${LABELS}

ENTRYPOINT ["jenkins-agent"]
