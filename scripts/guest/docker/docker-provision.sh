# Load all the -f docker compose file references that were saved earlier
dockerfilelist=$(</vagrant/.docker-compose-file-list)

echo "- - - (Re)building container images (volumes kept) - - -"
/usr/local/bin/docker-compose $dockerfilelist build

echo "- - - Creating and launching containers - - -"
/usr/local/bin/docker-compose $dockerfilelist up --no-build -d
