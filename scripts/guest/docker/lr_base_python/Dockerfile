######################################################################
# Dockerfile to build Python WSGI Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.2.1511

# Update system, despite a warning against this: https://docs.docker.com/articles/dockerfile_best-practices/#run
# The official CentOS Dockerfiles repo recommends it: https://github.com/CentOS/CentOS-Dockerfiles/blob/master/nginx/centos7/Dockerfile#L10
RUN yum clean all && \
  yum -q -y update

# To allow httpretty to install via pip3 (see https://github.com/pypa/pip/issues/1291)
ENV LC_ALL en_US.UTF-8

# Force stdin, stdout and stderr to be totally unbuffered
ENV PYTHONUNBUFFERED yes

# Set the log level to DEBUG for development
ENV LOG_LEVEL DEBUG

# DEPERECATED, HERE FOR TEMP BACK COMPAT ONLY: USE LOG_LEVEL INSTEAD
ENV FLASK_LOG_LEVEL DEBUG

# Install dev tools to allow python modules with native code (like markupsafe) to compile
RUN yum -q -y groupinstall "Development Tools" --skip-broken && \
  yum -q -y install wget

# Install python 3 then upgrade pip to latest version. Everything needs it so it goes here
RUN yum install -q -y https://raw.githubusercontent.com/LandRegistry-Ops/puppet-control/development/site/profiles/files/lr-python3-3.4.3-1.x86_64.rpm && \
  pip3 install --upgrade pip
