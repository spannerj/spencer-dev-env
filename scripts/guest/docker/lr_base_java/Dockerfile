######################################################################
# Dockerfile to build Java Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.2.1511

# Install Java and zip file support
# Also install make so the makefile can be used
RUN yum install -y -q java-1.8.0-openjdk-devel unzip wget which make

ENV GRADLE_HOME /opt/gradle/latest
ENV PATH $GRADLE_HOME/bin:$PATH
ENV GRADLE_INSTALLED_VERSION '3.2.1'

# Install gradle

RUN wget -q https://downloads.gradle.org/distributions/gradle-3.2.1-all.zip && \
  unzip -oqd /opt/gradle gradle-3.2.1-all.zip && \
  ln -sfn gradle-3.2.1 /opt/gradle/latest && \
  rm -f gradle-3.2.1-all.zip

# Default directory to run the app from
WORKDIR /src

# Port for frameworks such as spark
# Default to 8080, docker-compose can change this to the reserved port for this app
ENV PORT 8080

# Set the log level to DEBUG for development
ENV LOG_LEVEL DEBUG

# Set commit (for the health route) to be local for development
ENV COMMIT LOCAL

# Run gradle using the compiled classes (not creating a fat jar for deployment)
CMD ["gradle", "run"]
