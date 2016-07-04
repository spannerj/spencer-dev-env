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

  # Workaround because docker-compose create doesn't create network (only up does) and it's needed to create the containers
  docker network create dv_default

  echo "- - - (Re)creating docker containers - - -"
  /usr/local/bin/docker-compose create --no-build
fi

echo "- - - Removing any orphaned docker volumes - - -"
docker volume ls -qf dangling=true | xargs -r docker volume rm

echo "- - - Removing any orphaned docker images - - -"
images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  docker rmi $images
fi
