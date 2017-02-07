echo "- - - Building base docker python images - - -"
# If these haven't changed, the cache should be used and no app images will rebuild. Hopefully.
# We need a latest tag for the apps that don't specify a version (yet) as well
docker build -t lr_base_python:1 /vagrant/scripts/guest/docker/lr_base_python
docker build -t lr_base_python_flask:1 /vagrant/scripts/guest/docker/lr_base_python/flask
docker build -t lr_base_python:latest -t lr_base_python:2 /vagrant/scripts/guest/docker/lr_base_python2
docker build -t lr_base_python_flask:latest -t lr_base_python_flask:2 /vagrant/scripts/guest/docker/lr_base_python2/flask2

docker build -t lr_base_java:1 /vagrant/scripts/guest/docker/lr_base_java
docker build -t lr_base_java:latest -t lr_base_java:2 /vagrant/scripts/guest/docker/lr_base_java2

docker build -t lr_base_ruby:latest -t lr_base_ruby:1 /vagrant/scripts/guest/docker/lr_base_ruby

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

  echo "- - - (Re)creating docker containers - - -"
  /usr/local/bin/docker-compose create --no-build
fi

echo "- - - Removing any orphaned docker volumes - - -"
docker volume ls -qf dangling=true | xargs -r docker volume rm

echo "- - - Removing any orphaned docker images - - -"
images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  docker rmi -f $images
fi

# Needed for Elasticsearch 5.0 docker to run
sysctl -w vm.max_map_count=262144 > /dev/null 2>&1