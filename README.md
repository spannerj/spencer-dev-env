# Overview

This repository contains the code for a universal development environment that can be used across teams and projects. It is designed to allow collections of applications to be loaded from a separate configuration repository, while using a consistent environment. It is the result of lessons learnt from many other team's experiences with their own development environments and contains heavily researched configration settings and optimisations.

It provides several hooks for applications to take advantage of, including:

* Docker container creation and launching via docker-compose (base Python/Flask/Java images are provided to extend from)
* Automatic creation of commodity systems such as Postgres or Elasticsearch (with further hooks to allow for initial provisoning such as running SQL, Alembic DB upgrades or elasticsearch index creation)

# Changelog

* **v0.4.1** Updated Logstash config and Kibana saved searches to use new JSON log format.
* **v0.4.0** Added ELK stack support (#2) - see the [Logging section](#logging) for instructions. Reworked base Dockerfiles for increased efficiency and support for skeleton unit test structure. More aliases added, and tab-complete enabled for all aliases.
* **v0.3.1** Many optimisations and fixes (#16, #18)
* **v0.3.0** Added app-specific commodity provision tracking (#1). Fixed long line character overwriting issues in windows during SSH. Added aliases for common commands (#14).
* **v0.2.6** *BREAKING CHANGE* - Removed default CMD and SETTINGS env vars from base python/flask Dockerfiles. Apps must implement these themselves (although SETTINGS is not used in the current app structure).
* **v0.2.5** Updates for split app/alembic DB users (#11) and increased reload reliability.
* **v0.2.4** Fixed fatal error when doing a `vagrant reload` (#13)
* **v0.2.3** Fixed docker errors during vagrant up when no (docker) applications are specified in the configuration (#12)
* **v0.2.2** Updated base container centos versions, updated gradle version in java box. Fixed #10.
* **v0.2.1** Updated base vagrant box version, fixed a few provisioning bugs
* **v0.2** First public release

# Pre-requisites

## Software

* [Oracle VirtualBox](https://www.virtualbox.org/) (v5.0.14+)
* [Vagrant](https://www.vagrantup.com/) (v1.8+))
  * Make sure you do **not** have the vagrant-vbguest plugin installed. Any plugins the environment needs will be installed automatically.
* **_Windows users only_** [Git For Windows](http://git-for-windows.github.io) (download the portable zip version to get around any admin requirements) All the instructions in this README assume that you will be using Git Bash/MINGW64 which comes as part of this. It gives you a Unix-like shell and commands which make life much easier. While this software is technically optional, getting everything to work in the normal Windows command line is not covered here.

## Git/SSH

You must ensure the terminal you are starting the virtual machine from can access all the necessary Git repositories (depending where your config repo and application repos are - Internal GitLab, AWS GitLab, GitHub) via SSH. This usually means having all the appropriate keys in your SSH-agent. 

### Generation

To generate key(s) you can run `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`. You will then need to add them to your account's SSH Keys section on the relevent web site ([GitLab](http://docs.gitlab.com/ce/gitlab-basics/create-your-ssh-keys.html)/[GitHub](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/))

### Adding to agent

#### Mac

In your .bashrc or .zshrc add the following lines:

```shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

Repeat the `ssh-add` line for each key, changing the filename as appropriate.

#### Windows

Copy the contents of [this script snippet](http://192.168.249.38/common/dev-env/snippets/1) into your `~/.bash_profile` file, this will ensure all your keys get loaded into the agent (and only one agent executable ever runs). 

Note that this assumes that all the keys are placed in `~/.ssh` and all their names end in `_rsa`. If not, you will need to modify the script accordingly to load the right filenames.


# Quickstart

Run `vagrant up`

If this is the first time you are launching the machine you will be prompted for the url of your configuration repository. Paste it in and press enter.

# Guides

## Configuration Repository

[Example (workflow alpha)](http://git.lr.net/workflow/universal-devenv-workflow)

### `configuration.yml` (Mandatory)

The file lists the apps that should be pulled down, along with the (SSH) URL of their Git repository and which branch should be made active. The name of the app must match the repository name so that things like volume mappings in the app's docker-compose will hang together correctly. 

[Example](http://192.168.249.38/common/dev-env/snippets/3)

The repos will be pulled down and updated on each vagrant up, unless the current branch does not match the one in the configuration (this allows you to create and work in feature branches and be in full control of updates and merges).

### `environment.sh`

This is a shell script that will be executed inside the vagrant machine during the provisioning process (i.e. on the first `vagrant up` only, unless --provision is used). It can be used to modify the environment, change configuration of existing commodities, install new packages for trialling - basically anything you want.

If there is code added to support the needs of specific apps, then before those apps are ready to be used by the general populace (i.e. they could start appearing in other configuration repos) consideration should be given to whether the environment of the universal dev env needs to integrate them - as well as the ITO-controlled envornments (since they should match). Any changes will need to be assessed as to their impact on other apps.

### `after-up.sh`

As above, but gets executed on every `vagrant up` at the end of the process, after all the containers are started.

## Applications

For an application to leverage the full power of the universal development environment...

### Docker

To run an app, this environment uses Docker containers. So any app that wishes to be run in this way needs to provide some files to support that.

#### `/fragments/docker-compose-fragment.yml`

If this file exists, it will be used to construct the container (after building the image from the Dockerfile - see below) and then launch it. The standard rules are:

* Container name and service name should match
* The ports entry should map the internal Docker port to the app's default unique port as specified in it's configuration files
* The volumes entry should map the path of the app folder in the vagrant machine to /src.
* There should be no volumes entry for compiled apps such as Java as the files are already in the image.
* If the provided ELK stack is to be used, then a syslog logging driver needs to be present, forwarding to logstash.

[Example](http://192.168.249.38/common/dev-env/snippets/8)

#### `/Dockerfile`

This is the file that contructs the application container image. The standard rules are:

* There are base images provided that the app should extend (lr_base_python, lr_base_python_flask and lr_base_java - they have their own Dockerfiles in this repo that can be inspected if you wish to learn more about what they provide for you (for example, Flask provides a default command that runs gunicorn), but in general you can use the examples and just change the app-specific section to set variables and install any extra software via yum.
* Any environment variables that need to change to make it work within Docker over and above the application defaults (usually variables that require hostnames) should be specified.
* If there is a port environment variable, set it to 8080 (so that the docker-compose fragments are more consistent in their mappings)

Generally speaking, we are trying to keep anything Docker-specific contained in this file, so applications will still be runnable outside of Docker with no changes (and in the case of ITO-controlled regions, will be!).

You may notice that the example Java Dockerfile adds all files in the repo into the image so the source can be compiled. It is recommended you place a `.dockerignore` file in the application repo with the contents `.git` so that layer caching works correctly and the app image doesn't get rebuilt on every `vagrant up` (since the .git files get updated when the repo gets pulled).

[Example - Python/Flask](http://192.168.249.38/common/dev-env/snippets/6)

[Example - Java](http://192.168.249.38/common/dev-env/snippets/7)

### Commodities

#### `/configuration.yml`

This file lives in the root of the application and specifies which commodities the dev-env needs to create and launch in order for the application to connect to/use.

[Example](http://192.168.249.38/common/dev-env/snippets/2)

The commodities may require further files in order to set them up correctly, these are detailed below. Note that unless specified, any  fragment files will only be run once. This is controlled by a generated `.commodities.yml` file in the root of the dev-env, which you can change to allow the files to be read again - useful if you've added a new app to the configuration file 

#### `/fragments/postgres-init-fragment.sql` (postgres)

This file contains any SQL to run in postgres during the initial setup - at the minimum it will normally be creating a database and an application-specific user.

[Example](http://192.168.249.38/common/dev-env/snippets/4)

#### `/manage.py` (postgres)

This is a standard Alembic management file - if it exists, then a database migration will be run on every `vagrant up`.

#### `/fragments/db2-init-fragment.sql` (db2)

This file contains any SQL to run in DB2 during the initial setup - at the minimum it will normally be creating a database.

[Example](http://192.168.249.38/common/dev-env/snippets/9)

#### `/fragments/elasticsearch-fragment.sh` (elasticsearch)

This file is a shell script that contains curl commands to do any setup the app needs in elasticsearch - creating indexes etc. It will be passed a single argument, the hostname, which can be accessed in the script using `$1`.

[Example](http://192.168.249.38/common/dev-env/snippets/5)

## Logging

An ELK stack is created if any application requests the "logging" commodity. It will capture the output of any containers that are configured (via their docker-compose-fragment) to forward their messages to logstash via syslog.

Once some logs have been, well, logged, you can visit http://localhost:15601/ on your host machine and you'll get the Kibana welcome page. Choose "@timestamp" as your time-field name, and then you will be able to click the Create button, and start using it!

There are 3 saved searches available for you that you can open in the Discover tab. The display table will be set up to show the parsed information (assuming you are using the logging format defined in the skeleton-api). You can then turn on auto-refresh and enjoy! There is also a dashboard available that shows both searches on the same page.

To import them, go to Settings/Objects/Import and browse to `saved.json` in `/scripts/guest/docker/logging`.

# Useful commands

(In the below docker-compose examples you can leave out CONTAINERNAME and all containers will be affected)

`docker-compose rm -v -f CONTAINERNAME` (alias: remove) - Stops and removes a container and it's data.

`docker-compose down --rmi all -v --remove-orphans` - Stops and removes all containers, data, and images created by up. Don't use `--rmi all` if you want to keep the images.

`docker-compose stop|start|restart CONTAINERNAME` (aliases: stop/start/restart) - Starts, stops or restarts a container (it must already be built and created)

`docker-compose up --build -d CONTAINERNAME` (alias: rebuild) - Checks if a container needs rebuilding and rebuilds/recreates/restarts it if so, otherwise does nothing. Useful if you've just changed a requirements.txt file (or any Java code)

`docker exec -it CONTAINERNAME bash` (alias: bashin) - gets you into a bash terminal inside a running container (useful for then running psql etc)
