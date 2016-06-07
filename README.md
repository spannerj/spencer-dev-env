# Overview

This repository contains the code for a universal development environment that can be used across teams and projects. It is designed to allow collections of applications to be loaded from a separate configuration repository, while using a consistent environment. It is the result of lessons learnt from many other team's experiences with their own development environments and contains heavily researched configration settings and optimisations.

It provides several hooks for applications to take advantage of, including:
* Docker container creation and launching via docker-compose (base Python/Flask/Java images are provided to extend from)
* Automatic creation of commodity systems such as Postgres or Elasticsearch (with further hooks to allow for initial provisoning such as running SQL, Alembic DB upgrades or elasticsearch index creation)


#Pre-requisites

## Software
* [Oracle VirtualBox](https://www.virtualbox.org/) (v5.0+)
* [Vagrant](https://www.vagrantup.com/) (v1.8+))
* **_Windows users only_** [Git For Windows](http://git-for-windows.github.io) (download the portable zip version to get around any admin requirements) All the instructions in this README assume that you will be using Git Bash/MINGW64 which comes as part of this. It gives you a Unix-like shell and commands which make life much easier. While this software is technically optional, getting everything to work in the normal Windows command line is not covered here.

## Git/SSH

You must ensure the terminal you are starting the virtual machine from can access all the necessary Git repositories (depending where your config repo and application repos are - Internal GitLab, AWS GitLab, GitHub) via SSH. This usually means having all the appropriate keys in your SSH-agent. 

### Generation
To generate key(s) you can run `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`. You will then need to add them to your account's SSH Keys section on the relevent web site ([GitLab](http://docs.gitlab.com/ce/gitlab-basics/create-your-ssh-keys.html)/[GitHub](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

#### Adding to agent

##### Mac

In your .bashrc or .zshrc add the following lines (change id_rsa to the name of your key):

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```
Repeat the `ssh-add` line for each key.

##### Windows

Copy the contents of [this script snippet](http://192.168.249.38/common/dev-env/snippets/1) into your `~/.bash_profile` file, this will ensure all your keys get loaded into the agent (and only one agent executable ever runs). 

Note that this assumes that all the keys are placed in `~/.ssh` and all their names end in `_rsa`. If not, you will need to modify the script accordingly to load the right filenames.


#Quickstart

Run `vagrant up`

If this is the first time you are launching the machine you will be prompted for the url of your configuration repo. Paste it in and press enter.