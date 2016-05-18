#Install docker
echo "- - - Installing Docker - - -"
cat > /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
yum -y -q install docker-engine
service docker start
chkconfig docker on
usermod -a -G docker vagrant

echo "- - - Installing Docker Compose - - -"
#Install Docker compose
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
export PATH=$PATH:/usr/local/bin
echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/add_local_bin.sh

echo "- - - Removing any existing containers (and their data volumes) - - -"
# TODO fix
docker ps -a -q | xargs docker rm -v -f

images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  echo "- - - Removing orphaned docker images - - -"
  docker rmi $images
fi

echo "- - - Building base docker python image - - -"
docker build -t lr_base_python /vagrant/scripts/guest/docker/lr_base_python
