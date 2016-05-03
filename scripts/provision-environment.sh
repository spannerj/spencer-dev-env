#Install git so that the app-groupings repo and ultimately the apps can be cloned/pulled into the environment
echo 'Installing git'
yum -y install git

#Add AWS Gitlab to the known_hosts file
echo "192.168.249.38 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD/rQkp8cBGqVj4mNG9I6nx2w4gzpG61dUj9VnREKpIE9iaDbC9BoeOE48zCzkT+uBk0c+acvEu5dlivgREgkJM=" > /home/vagrant/.ssh/known_hosts
chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
chmod 600 /home/vagrant/.ssh/known_hosts

cd /vagrant

ssh-add -l

#Pull down the app_list specified as the vagrant user.
su vagrant -c "git clone $1 app_list"


