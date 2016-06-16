## Install a whole bunch of ruby dependencies
sudo yum -y -q install patch libyaml-devel libffi-devel sqlite-devel readline-devel zlib-devel openssl-devel bison fontconfig freetype-devel fontconfig-devel

# Install RVM and then Ruby
curl -#LO https://rvm.io/mpapis.asc
gpg --import mpapis.asc
curl -L get.rvm.io | bash -s stable 
source ~/.profile
source ~/.rvm/scripts/rvm 
rvm install 2.3.1 
rvm use 2.3.1 --default 
gem install bundler

## Install Phantomjs
export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
wget -q https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 
sudo mv $PHANTOM_JS.tar.bz2 /usr/local/share/ 
cd /usr/local/share/ 
sudo tar xvjf $PHANTOM_JS.tar.bz2 
sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/share/phantomjs 
sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs 
sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/bin/phantomjs