HOME='/home/vagrant'

# Customise the shell prompt you see when SSHing into the box.
# First, remove any existing setting of PS1 from bash profile (prevents duplicates)
sed -i -e 's/.*PS1.*//' ${HOME}/.bash_profile
# Now add our own customisation:
# \033[X;XXm sets a colour
# \w prints the current path 
# \$ shows the appropriate cursor depending on what type of user is logged in.
echo 'export PS1=" \033[1;34mDEVENV \033[0;35m\w \033[1;31m\$ \033[0m"' >> ${HOME}/.bash_profile

# Just for ease of use, let's autoswap to the shared workspace folder when the shell launches
# First, remove any existing setting of it from bash profile (prevents duplicates)
sed -i -e 's/.*switch to workspace//' ${HOME}/.bash_profile
echo 'cd /vagrant; # switch to workspace' >> ${HOME}/.bash_profile

# Update all packages (except kernel files - prevents guest additions breakage)
yum -y -q --exclude=kernel\* update

#Install git so that the app-groupings repo and ultimately the apps can be cloned/pulled into the environment
echo 'Installing git'
yum -y -q install git

#Add AWS Gitlab to the known_hosts file
echo "192.168.249.38 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD/rQkp8cBGqVj4mNG9I6nx2w4gzpG61dUj9VnREKpIE9iaDbC9BoeOE48zCzkT+uBk0c+acvEu5dlivgREgkJM=" > /home/vagrant/.ssh/known_hosts
chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
chmod 600 /home/vagrant/.ssh/known_hosts

cd /vagrant

ssh-add -l

#Pull down the app_list specified as the vagrant user.
su vagrant -c "git clone $1 app_list"


