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
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
export PATH=$PATH:/usr/local/bin
echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/add_local_bin.sh

echo "- - - Removing all existing docker containers (and their data volumes) - - -"
docker ps -a -q | xargs docker rm -v -f

echo "- - - Removing any orphaned docker images - - -"
images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  docker rmi $images
fi

echo "- - - Building base docker python images - - -"
docker build -t lr_base_python /vagrant/scripts/guest/docker/lr_base_python
docker build -t lr_base_python_flask /vagrant/scripts/guest/docker/lr_base_python/flask
docker build -t lr_base_java /vagrant/scripts/guest/docker/lr_base_java
