Overview
=====

This repository contains the code for common development environment that can be used across teams and projects.

Pre-requisites
=====

SSH forwarding is enabled and it is assumed that you will be adding the correct keys to the agent to allow pull of git repos from within the development environment. 

On a mac:

In your .bashrc or .zshrc add the following lines (change id_rsa to the name of your key):

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

On windows:

This sections assumes you already have ssh keys for accessing Gitlab/Github and they are found here ~/.ssh.

You can use Pageant to do the equivalent of ssh-add. Download puttygen.exe and pageant.exe from [here](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) and also download ssh-pageant.exe from [here](https://github.com/cuviper/ssh-pageant/releases). Put all three exes into a folder, then add the following lines to your .bashrc or .zshrc (or whatever script runs during start up of your shell) replacing "/usr/local/bin" with the path the folder with the three puttu/pageant exes in it and replace "~/.ssh" to the path where your keys are:

```
/usr/local/bin/pageant ~/.ssh/*.ppk &  

eval $(/usr/local/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
```

You will need to convert your rsa keys to ppk. Double click on puttygen.exe. Then convert the key using the following: (Conversions->import key->Select key->Save private key). Save them in the same place as your rsa keys.


Quickstart
=====

Create a git repo that will contain the list of applications that will be run inside in the development environment. Then run

```
vagrant up
```

You will be prompted for the url of your application list - "Please enter the url of your app list:". Paste in your url and hit enter.

The application list will be cloned into a folder called app_list.