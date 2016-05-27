# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure essential plugins are installed
require_relative 'scripts/host/plugin_manager'
require_relative 'scripts/host/update_apps'
require_relative 'scripts/host/utilities'
require_relative 'scripts/host/docker_compose'
require_relative 'scripts/host/expose_ports'
require_relative 'scripts/host/postgres_init'
require_relative 'scripts/host/alembic_provision'
require_relative 'scripts/host/db2_provision'
require_relative 'scripts/host/dependencies'
require 'fileutils'

# If user is doing a reload, do a vagrant halt then up instead (keeping all parameters except the reload)
# so that the up trigger works and we can do stuff while the machine is stopped
if ['reload'].include? ARGV[0]
  ARGV.shift # Remove the reload command
  puts colorize_lightblue("Vagrant reload detected. I'm going to do a separate halt/up instead.")
  # These have to be separate commands else ruby complains on the up
  system ("vagrant halt")
  exec "vagrant up #{ARGV.join(' ')}"
end

# If plugins have been installed, rerun the original vagrant command and abandon this one
if not check_plugins ["vagrant-cachier", "vagrant-triggers", "vagrant-reload", "vagrant-persistent-storage"]
  exec "vagrant #{ARGV.join(' ')}" unless ARGV[0] == 'plugin'
end

# Define the DEV_ENV_CONTEXT_FILE file name to store the users app_grouping choice
# As vagrant up can be run from any subdirectory, we must make sure it is stored alongside the Vagrantfile
DEV_ENV_CONTEXT_FILE = File.dirname(__FILE__) + "/.dev-env-context"

Vagrant.configure(2) do |config|
  config.vm.box              = "landregistry/centos"
  config.vm.box_version      = "0.3.0"
  config.vm.box_check_update = false
  config.ssh.forward_agent = true

  # Configure cached packages to be shared between instances of the same base box.
 	# More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
  config.cache.scope       = :box
  # Make cachier only cache yum instead of rooting about trying to figure things out itself
  config.cache.auto_detect = false
  config.cache.enable :yum

  # Docker persistent storage (cachier can't cope)
  config.persistent_storage.enabled = true
  config.persistent_storage.location = File.dirname(__FILE__) + "/docker_storage.vdi"
  config.persistent_storage.size = 50000
  config.persistent_storage.mountpoint = '/var/lib/docker'

  # Only if vagrant up/resume do we want to create dev-env configuration
  if ['up', 'resume'].include? ARGV[0]
    # Check if a DEV_ENV_CONTEXT_FILE exists, to prevent prompting for dev-env configuration choice on each vagrant up
    if File.exists?(DEV_ENV_CONTEXT_FILE)
      puts colorize_lightblue("This dev env has been provisioned to run for the repo: #{File.read(DEV_ENV_CONTEXT_FILE)}")
    else
      puts colorize_lightblue("This is a universal dev env.")
      print colorize_yellow("Please enter the url of your dev env repo (SSH): ")
      app_grouping = STDIN.gets.chomp
      File.open(DEV_ENV_CONTEXT_FILE, "w+") { |file| file.write(app_grouping) }
    end

    # Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
    puts colorize_lightblue("Retrieving custom configuration repo files:")
    if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
      command_successful = system 'git', '-C', File.dirname(__FILE__) + '/dev-env-project', 'pull'
    else
      command_successful = system 'git', 'clone', File.read(DEV_ENV_CONTEXT_FILE), File.dirname(__FILE__) + '/dev-env-project'
    end

    # Error if git clone or pulling failed
    if command_successful == false
      puts colorize_red("Something went wrong when cloning/pulling the dev-env configuration project")
      exit 1
    end

    # Call the ruby function to pull/clone all the apps found in dev-env-project/configuration.yml
    puts colorize_lightblue("Updating apps:")
    update_apps(File.dirname(__FILE__))

    # Create a file called .dependencies.yml with the list of dependencies in it
    puts colorize_lightblue("Creating list of dependencies")
    create_dependencies_list(File.dirname(__FILE__))

    # Call the ruby function to create the docker compose file containing the apps and their dependencies
    puts colorize_lightblue("Creating docker-compose")
    prepare_compose(File.dirname(__FILE__))

    # Call the ruby function to check the apps for an SQL snippet to add to the SQL that gets run when the postgres container starts up.
    # This only happens once, so to rerun it if it changes, the postgres container and it's volume will need to be removed first.
    # Either via 1) 'docker rm -v -f postgres' followed by a ( a) docker-compose up --build, or b) vagrant reload if the app configs need reparsing),
    # or 2) a vagrant reload --provision (but this will wipe ALL containers)
    prepare_postgres(File.dirname(__FILE__))

    # Find the ports of the apps and dependencies on the host and add port forwards for them
    create_port_forwards(File.dirname(__FILE__), config)
  end

  # In the event of user requesting a vagrant destroy
  config.trigger.before :destroy do
    # remove DEV_ENV_CONTEXT_FILE created on provisioning
    confirm = nil
    until ["Y", "y", "N", "n"].include?(confirm)
      confirm = ask colorize_yellow("Would you like to keep your custom dev-env configuration files? (Y/N) ")
    end
    if confirm.upcase == "N"
      File.delete(DEV_ENV_CONTEXT_FILE)
      if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
        FileUtils.rm_r File.dirname(__FILE__) + '/dev-env-project'
      end
    end
    # remove .dependencies.yml created on provisioning
    if Dir.exists?(File.dirname(__FILE__) + '/.dependencies.yml')
      FileUtils.rm_r File.dirname(__FILE__) + '/.dependencies.yml'
    end
  end

  # Run script to configure environment
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/provision-environment.sh"

  # Install docker and docker-compose
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/docker/install-docker.sh"

  # Build and start all the containers
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/docker/docker-provision.sh", run: "always"

  # Update Virtualbox Guest Additions
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/setup-vboxguest.sh"

  #Reload VM after Guest Additions have been installed, so that shared folders work.
  #Always force reload last, after every provisioner has run, otherwise if a provisioner
  #is set to always run it will get run twice.
  config.vm.provision :reload

  # Once the machine is fully configured and (re)started, run some more stuff
  config.trigger.after [:up, :resume] do
    # Alembic
    provision_alembic(File.dirname(__FILE__))
    # Run app DB2 SQL statements
    provision_db2(File.dirname(__FILE__))
  end

  config.vm.provider :virtualbox do |vb|
  # Set a random name to avoid a folder-already-exists error after a destroy/up (virtualbox often leaves the folder lying around)
    vb.name = "landregistry-development #{Time.now.to_f}"
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 4096]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
    vb.customize ['modifyvm', :id, '--paravirtprovider', 'kvm']
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
  end
end
