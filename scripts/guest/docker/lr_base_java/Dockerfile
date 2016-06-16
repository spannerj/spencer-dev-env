######################################################################
# Dockerfile to build Java Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.1.1503

# Install Java and zip file support
RUN yum install -y -q java-1.8.0-openjdk-devel unzip wget

ENV GRADLE_HOME /opt/gradle/latest
ENV PATH $GRADLE_HOME/bin:$PATH
ENV GRADLE_INSTALLED_VERSION '2.13'

# Install gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.13-all.zip && \
  unzip -oqd /opt/gradle gradle-2.13-all.zip && \
  ln -sfn gradle-2.13 /opt/gradle/latest  && \
  rm -f gradle-2.13-all.zip