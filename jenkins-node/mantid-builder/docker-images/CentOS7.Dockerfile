FROM mantidproject/mantid-development-centos7:latest

# Install dependencies
RUN yum install -y \
      curl \
      java-1.8.0-openjdk && \
    rm -rf /tmp/* /var/tmp/*

# Setup Jenkins agent
ARG JENKINS_AGENT_VERSION=3.9
RUN mkdir -p /jenkins_workdir && \
    chmod o+rw /jenkins_workdir && \
    curl \
      --location \
      --create-dirs \
      --output /usr/share/jenkins/agent.jar \
      "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_AGENT_VERSION}.jar" && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/agent.jar && \
    # Remove passwordless sudo for CI runner
    rm /etc/sudoers.d/abc_sudo_with_no_passwd
ENV AGENT_WORKDIR=/jenkins_workdir
COPY jenkins_agent /usr/share/jenkins/agent.sh

# Add passwordless access required for systemtests
ADD abc_systemtests_sudoer_centos \
    /etc/sudoers.d/abc_systemtests_sudoer_centos

VOLUME ["/jenkins_workdir"]

ADD entrypoint.d/* /etc/entrypoint.d/

# Run Jenkins agent script
CMD ["/usr/share/jenkins/agent.sh"]
