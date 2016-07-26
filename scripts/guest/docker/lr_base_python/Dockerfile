######################################################################
# Dockerfile to build Python WSGI Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.2.1511

# To allow httpretty to install via pip3 (see https://github.com/pypa/pip/issues/1291)
ENV LC_ALL en_US.UTF-8

# Force stdin, stdout and stderr to be totally unbuffered
ENV PYTHONUNBUFFERED yes

# Update all packages and install dev tools to allow python modules with native code (like markupsafe) to compile
RUN yum -q -y update && \
  yum -q -y groupinstall "Development Tools" --skip-broken && \
  yum -q -y install wget && \
  mkdir /logs && \ 
  chmod 777 -R /logs
# TODO decide logs tactic

# Install python 3 then upgrade pip to latest version. Everything needs it so it goes here
RUN yum install -y https://raw.githubusercontent.com/LandRegistry-Ops/puppet-control/development/site/profiles/files/lr-python3-3.4.3-1.x86_64.rpm && \
  pip3 install --upgrade pip