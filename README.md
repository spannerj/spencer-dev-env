# Overview

This repository contains the code for a universal development environment that can be used across teams and projects. It is designed to allow collections of applications to be loaded from a separate configuration repository, while using a consistent environment. It is the result of lessons learnt from many other team's experiences with their own development environments and contains heavily researched configration settings and optimisations.

It provides several hooks for applications to take advantage of, including:
* Docker container creation and launching via docker-compose (base Python/Flask/Java images are provided to extend from)
* Automatic creation of commodity systems such as Postgres or Elasticsearch (with further hooks to allow for initial provisoning such as running SQL, Alembic DB upgrades or elasticsearch index creation)


# Pre-requisites

## Software
* [Oracle VirtualBox](https://www.virtualbox.org/) (v5.0+)
* [Vagrant](https://www.vagrantup.com/) (v1.8+))
* **_Windows users only_** [Git For Windows](http://git-for-windows.github.io) (download the portable zip version to get around any admin requirements) All the instructions in this README assume that you will be using Git Bash/MINGW64 which comes as part of this. It gives you a Unix-like shell and commands which make life much easier. While this software is technically optional, getting everything to work in the normal Windows command line is not covered here.

## Git/SSH

You must ensure the terminal you are starting the virtual machine from can access all the necessary Git repositories (depending where your config repo and application repos are - Internal GitLab, AWS GitLab, GitHub) via SSH. This usually means having all the appropriate keys in your SSH-agent. 

### Generation
To generate key(s) you can run `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`. You will then need to add them to your account's SSH Keys section on the relevent web site ([GitLab](http://docs.gitlab.com/ce/gitlab-basics/create-your-ssh-keys.html)/[GitHub](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/))

### Adding to agent

#### Mac

In your .bashrc or .zshrc add the following lines (change id_rsa to the name of your key):

```shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```
Repeat the `ssh-add` line for each key.

#### Windows

Copy the contents of [this script snippet](http://192.168.249.38/common/dev-env/snippets/1) into your `~/.bash_profile` file, this will ensure all your keys get loaded into the agent (and only one agent executable ever runs). 

Note that this assumes that all the keys are placed in `~/.ssh` and all their names end in `_rsa`. If not, you will need to modify the script accordingly to load the right filenames.


# Quickstart

Run `vagrant up`

If this is the first time you are launching the machine you will be prompted for the url of your configuration repository. Paste it in and press enter.

# Guides

## Configuration Repository

### (Mandatory) configuration.yml
The file lists the apps that should be pulled down, along with the (SSH) URL of their Git repository and which branch should be made active. The name of the app must match the repository name so that things like volume mappings in the app's docker-compose will hang together correctly. 

Example:
```yaml
applications:

  workflow-allocation-frontend:
    repo: git@git.lr.net:workflow/workflow-allocation-frontend.git
    branch: develop
  
  workflow-identify-api:
    repo: git@git.lr.net:workflow/workflow-identify-api.git
    branch: develop
```

The repos will be pulled down and updated on each vagrant up, unless the current branch does not match the one in the configuration (this allows you to create and work in feature branches and be in full control of updates and merges).

### (Optional) environment.sh

This is a shell script that will be executed inside the vagrant machine during the provisioning process (i.e. on the first `vagrant up` only, unless --provision is used). It can be used to modify the environment, change configuration of existing commodities, install new packages for trialling - basically anything you want.

If there is code added to support the needs of specific apps, then before those apps are ready to be used by the general populace (i.e. they could start appearing in other configuration repos) consideration should be given to whether the environment of the universal dev env needs to integrate them - as well as the ITO-controlled envornments (since they should match). Any changes will need to be assessed as to their impact on other apps.

### (Optional) after-up.sh

As above, but gets executed on every `vagrant up` at the end of the process, after all the containers are started.

## Applications

For an application to leverage the full power of the universal development environment...

### dependencies.yml

#### fragments/postgres-init-fragment.sql

#### manage.py

#### fragments/db2-init-fragment.sql

#### fragments/elasticsearch-fragment.sh

### fragments/docker-compose-fragment.yml

#### Dockerfile
