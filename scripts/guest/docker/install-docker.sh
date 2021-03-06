# Install support for overlayfs (the default in docker 1.13+)
yum -y -q install yum-plugin-ovl

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
yum -y -q install docker-engine bash-completion
service docker start
chkconfig docker on
usermod -a -G docker vagrant

echo "- - - Installing Docker Compose - - -"
#Install Docker compose
curl -L https://github.com/docker/compose/releases/download/1.11.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
export PATH=$PATH:/usr/local/bin
echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/add_local_bin.sh

# Bash autocompletion of container names
wget -q https://raw.githubusercontent.com/docker/compose/1.11.0/contrib/completion/bash/docker-compose
mv -f docker-compose /etc/bash_completion.d/docker-compose

echo "- - - Removing all existing docker containers (and their data volumes) - - -"
docker ps -a -q | xargs docker rm -v -f

echo "- - - Removing any orphaned docker images - - -"
images=$(docker images -f "dangling=true" -q)
if [ -n "$images" ]; then
  docker rmi $images
fi
