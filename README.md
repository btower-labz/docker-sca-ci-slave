# SCA CI SLAVE IMAGE

This is an image for [Jenkins](https://jenkins.io) agent (FKA "slave") using either swarm or slave to establish connection.

Slave mode is powered by the [Jenkins Remoting library](https://github.com/jenkinsci/remoting)
Slave code is being taken from [the repo](https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/).

Swarm mode is powered by the [Jenkins Swarm Plugin](https://wiki.jenkins.io/display/JENKINS/Swarm+Plugin)
Swarm code is being taken from [the repo](https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/)

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more info.

## Running

To run a Docker container

    docker run btowerlabs/docker-sca-ci-slave

Optional environment variables:

* `XXX`: aaa
* `AAA`: (`BBB:CCC`) ddd.
