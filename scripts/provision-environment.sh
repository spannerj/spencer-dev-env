#Install git so that the app-groupings repo and ultimately the apps can be cloned/pulled into the environment
echo 'Installing git'
yum -y install git

#Add AWS Gitlab to the known_hosts file
echo "192.168.249.38 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD/rQkp8cBGqVj4mNG9I6nx2w4gzpG61dUj9VnREKpIE9iaDbC9BoeOE48zCzkT+uBk0c+acvEu5dlivgREgkJM=" > /home/vagrant/.ssh/known_hosts
chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
chmod 600 /home/vagrant/.ssh/known_hosts

#Load the content of the file found at /vagrant/$1 where $1 is the first parameter passed to this script. $1 is likely to be ".dev-env-context".
app_list_url=$(</vagrant/$1)

cd /vagrant

#Pull down the app_list specified as the vagrant user.
su vagrant -c "git clone $app_list_url app_list"


