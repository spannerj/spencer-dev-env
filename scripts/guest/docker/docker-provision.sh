# Needed for Elasticsearch 5.0 docker to run
sudo sysctl -w vm.max_map_count=262144 > /dev/null 2>&1

echo "- - - Pulling base docker python images - - -"
# If these haven't changed, the cache should be used and no app images will rebuild. Hopefully.

# Build and push commands to run after updating the Dockerfile(s) are contained in http://192.168.249.38/common/dev-env/snippets/10

# We need a latest tag for the apps that don't specify a version (yet) as well

# Python
docker pull --all-tags hmlandregistry/dev_base_python
# Retag for apps to use in their FROM
docker tag hmlandregistry/dev_base_python:latest lr_base_python:latest
docker tag hmlandregistry/dev_base_python:1 lr_base_python:1
docker tag hmlandregistry/dev_base_python:2 lr_base_python:2

# Flask (extends Python)
docker pull --all-tags hmlandregistry/dev_base_python_flask
# Retag for apps to use in their FROM
docker tag hmlandregistry/dev_base_python_flask:latest lr_base_python_flask:latest
docker tag hmlandregistry/dev_base_python_flask:1 lr_base_python_flask:1
docker tag hmlandregistry/dev_base_python_flask:2 lr_base_python_flask:2

# Java
docker pull --all-tags hmlandregistry/dev_base_java
# Retag for apps to use in their FROM
docker tag hmlandregistry/dev_base_java:latest lr_base_java:latest
docker tag hmlandregistry/dev_base_java:1 lr_base_java:1
docker tag hmlandregistry/dev_base_java:2 lr_base_java:2


# Ruby
docker pull --all-tags hmlandregistry/dev_base_ruby
# Retag for apps to use in their FROM
docker tag hmlandregistry/dev_base_ruby:latest lr_base_ruby:latest
docker tag hmlandregistry/dev_base_ruby:1 lr_base_ruby:1


# Got to use a constant project name to ensure that containers are properly tracked regardless of how fragments are added are removed. Otherwise you get duplicate errors on the build
export COMPOSE_PROJECT_NAME=dv

# Load all the docker compose file references that were saved earlier
dockerfilelist=$(</vagrant/.docker-compose-file-list)
export COMPOSE_FILE=$dockerfilelist

# Let's put the env vars into the vagrant users bash profile, so that manual docker-compose commands will "just work"
HOME='/home/vagrant'
sed -i -e 's/.*COMPOSE_PROJECT_NAME.*//' ${HOME}/.bash_profile
sed -i -e 's/.*COMPOSE_FILE.*//' ${HOME}/.bash_profile
echo "export COMPOSE_PROJECT_NAME='$COMPOSE_PROJECT_NAME'" >> ${HOME}/.bash_profile
echo "export COMPOSE_FILE='$COMPOSE_FILE'" >> ${HOME}/.bash_profile

# If there's docker apps (the var is not empty), then do docker stuff
if ! [ -z "$COMPOSE_FILE" ]; then
  echo "- - - (Re)building docker images (volumes kept) - - -"
  /usr/local/bin/docker-compose build
  # If the exit code of the build command was not 0 (i.e. it failed) then bomb out of the whole process here so it's obvious to the user where an image failed to build
  rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

  # Workaround because docker-compose create doesn't create network (only up does) and it's needed to create the containers
  if docker network ls | grep -q "dv_default"; then
    echo "Docker network already exists, skipping creation"
  else
    docker network create dv_default
  fi
fi

echo "- - - Removing any orphaned docker volumes - - -"
docker volume ls -qf dangling=true | xargs -r docker volume rm

echo "- - - Removing any orphaned docker images - - -"
images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  docker rmi -f $images
fi