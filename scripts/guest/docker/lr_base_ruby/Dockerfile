######################################################################
# Dockerfile to build Ruby Application Containers
# Based on Debian
######################################################################

# Set the base image to the official ruby image. NOTE: By specifying the minor version tag, it will not receive updates!
FROM ruby:2.3.3

## Install Phantomjs
RUN export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
  curl -L -S -O https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2  && \
  mv $PHANTOM_JS.tar.bz2 /usr/local/share/  && \
  cd /usr/local/share/  && \
  tar xvjf $PHANTOM_JS.tar.bz2  && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/share/phantomjs  && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs  && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/bin/phantomjs

