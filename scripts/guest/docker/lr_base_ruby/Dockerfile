######################################################################
# Dockerfile to build Ruby Application Containers
# Based on CentOS
######################################################################

# Set the base image to Centos. NOTE: By specifying the minor version tag, it will not receive updates!
FROM centos:centos7.2.1511

# Update system, despite a warning against this: https://docs.docker.com/articles/dockerfile_best-practices/#run
# The official CentOS Dockerfiles repo recommends it: https://github.com/CentOS/CentOS-Dockerfiles/blob/master/nginx/centos7/Dockerfile#L10
RUN yum clean all && \
  yum -q -y update

# Install rbenv system dependencies
RUN yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel \
  openssl-devel make bzip2 autoconf automake libtool bison iconv-devel git-core

# Create the unprivileged application user and switch user
RUN groupadd app-group; useradd -g app-group --home-dir /home/app app
USER app

# Setup unprivileged user environmental variables
ENV RBENV_ROOT /home/app/.rbenv
ENV PATH ${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH

# Install rbenv, ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git $RBENV_ROOT && \
  git clone https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build && \
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# Install ruby specified RBENV_VERSION
ENV RBENV_VERSION 2.3.1
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.3.1; rbenv init -

# Set gem config
# Then install bundler, rehash
RUN mkdir $( dirname $(ruby -e 'print Gem::ConfigFile::SYSTEM_WIDE_CONFIG_FILE') ) && \
  echo 'gem: --no-document' >> $(ruby -e 'print Gem::ConfigFile::SYSTEM_WIDE_CONFIG_FILE') && \
  gem install bundler; rbenv rehash
