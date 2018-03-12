# Jenkins basic slave image for SCA project.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices

FROM openjdk:8-jdk
MAINTAINER btower-labz <labz@btower.net>

LABEL Name="docker-sca-ci-slave"
LABEL Vendor="btower-labz"
LABEL Version="1.0.0"
LABEL Description="Provides basic sca ci agent, either slave or swarm mode"

ENV HOME /home/jenkins
ENV SWARM_DESCRIPTION "sca swarm agent"

ARG SLAVE_VERSION=3.9
ARG SWARM_VERSION=3.4
ARG JAR_PATH=/usr/share/jenkins
ARG SRC_PATH=/usr/local/src
ARG SWARM_REPO=https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client
ARG SLAVE_REPO=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting
ARG LABELS=/home/jenkins/swarm-labels.cfg

USER root

# Add jenkins user
RUN groupadd -g 1092310000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 1092310000 -g 1092310000 -m jenkins

# Install additional software
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y apt-utils && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y curl git unzip lsof nano wget subversion && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y ant ant-doc ant-optional ant-contrib && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y maven maven-ant-helper && rm -rf /var/lib/apt/lists/*
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

# Install agent script
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod ugo+x /usr/local/bin/jenkins-agent

# Install slave
COPY install-slave /tmp/install-slave
RUN chmod u+x /tmp/install-slave && /tmp/install-slave

# Install swarm
COPY install-swarm /tmp/install-swarm
RUN chmod u+x /tmp/install-swarm && /tmp/install-swarm

# Initialize labels
RUN touch ${LABELS}; printf " sca ant maven" >>${LABELS}; chown jenkins:jenkins ${LABELS}; ls -la ${LABELS};

USER jenkins

RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

# Show info in build log
RUN uname -a; cat /etc/issue; cat ${LABELS}

ENTRYPOINT ["jenkins-agent"]
