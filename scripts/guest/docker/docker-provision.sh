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


echo "- - - (Re)building container images (volumes kept) - - -"
/usr/local/bin/docker-compose build

echo "- - - Creating and launching containers - - -"
/usr/local/bin/docker-compose up --no-build -d
