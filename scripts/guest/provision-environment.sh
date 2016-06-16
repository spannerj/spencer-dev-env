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
echo 'Updating all currently installed non-kernel packages'
yum -y -q --exclude=kernel\* update

# Ruby
# Run external script as vagrant user. Running as root does not play nicely with RVM
sudo -i -u vagrant source /vagrant/scripts/guest/install-ruby.sh
