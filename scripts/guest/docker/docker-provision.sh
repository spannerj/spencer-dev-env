echo "- - - (Re)building container images (volumes kept) - - -"
/usr/local/bin/docker-compose -f /vagrant/scripts/guest/docker/docker-compose.yml build

echo "- - - Creating and launching containers - - -"
/usr/local/bin/docker-compose -f /vagrant/scripts/guest/docker/docker-compose.yml up --no-build -d
