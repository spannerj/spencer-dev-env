######################################################################
# Dockerfile to build Java Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.2.1511

# Install Java and zip file support
RUN yum install -y -q java-1.8.0-openjdk-devel unzip wget which

ENV GRADLE_HOME /opt/gradle/latest
ENV PATH $GRADLE_HOME/bin:$PATH
ENV GRADLE_INSTALLED_VERSION '3.0'

# Install gradle

RUN wget -q https://downloads.gradle.org/distributions/gradle-3.0-all.zip && \
  unzip -oqd /opt/gradle gradle-3.0-all.zip && \
  ln -sfn gradle-3.0 /opt/gradle/latest && \
  rm -f gradle-3.0-all.zip

# Default directory to run the app from
WORKDIR /src

# Run gradle using the compiled classes (not creating a fat jar for deployment)
CMD ["gradle", "run"]
