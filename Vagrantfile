# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure essential plugins are installed
require_relative 'scripts/host/plugin_manager'
require_relative 'scripts/host/update_apps'
require_relative 'scripts/host/utilities'
require_relative 'scripts/host/docker_compose'
require_relative 'scripts/host/expose_ports'
require_relative 'scripts/host/postgres_provision'
require_relative 'scripts/host/nginx_provision'
require_relative 'scripts/host/alembic_provision'
require_relative 'scripts/host/db2_provision'
require_relative 'scripts/host/commodities'
require_relative 'scripts/host/elasticsearch_provision'
require_relative 'scripts/host/supporting_files'
require_relative 'scripts/host/self_update'
require 'fileutils'

# Where is this file located?
root_loc = File.dirname(__FILE__)

# Find out where persistent storage file might live
if ENV.has_key?('VAGRANT_HOME') # Overidden by user
  docker_storage_location = ENV['VAGRANT_HOME'] + "/cache/docker_storage.vdi"
elsif ENV.has_key?('USERPROFILE') # Windows default
  docker_storage_location = ENV['USERPROFILE'] + "/.vagrant.d/cache/docker_storage.vdi"
elsif ENV.has_key?('HOME') # Linux/OSX default
  docker_storage_location = ENV['HOME'] + "/.vagrant.d/cache/docker_storage.vdi"
else # Last resort
  docker_storage_location = "~/.vagrant.d/cache/docker_storage.vdi"
end

# Only if vagrant up do we want to check for plugins. Since it's only a one off really.
if ['up'].include? ARGV[0]
  # If plugins have been installed, rerun the original vagrant command and abandon this one
  if not check_plugins ["vagrant-cachier", "vagrant-triggers"]
    puts colorize_yellow("Please rerun your command (vagrant #{ARGV.join(' ')})")
    exit 0
  end
end

# If user is doing a reload, the raw script commands like updating app repos will be done before the machine halts.
# So stop the apps now, just so they don't try to reload and run any new code.
if ['reload', 'halt'].include? ARGV[0]
  if File.exists?(root_loc + '/.docker-compose-file-list') && File.size(root_loc + '/.docker-compose-file-list') != 0
    # If this file exists it must have previously got to the point of creating the containers
    # and if it has something in we know there are apps to stop and won't get an error
    puts colorize_lightblue('Stopping apps')
    system "vagrant ssh -c \"docker-compose stop\""
  end
end

# If a quick reload file has been created, we'll skip the up/resume/reload section below, so no dev-env or app updates
QUICK_RELOAD_FILE = root_loc + "/.quick-reload"
quick_reload = false
if ['up', 'resume', 'reload'].include?(ARGV[0]) && File.exists?(QUICK_RELOAD_FILE)
  quick_reload = true
  File.delete(QUICK_RELOAD_FILE)
  puts colorize_lightblue("Quick reload request detected. Whoosh!")
end


# Only if vagrant up/resume do we want to check for update
if ['up', 'resume', 'reload'].include?(ARGV[0]) && quick_reload == false
  this_version = "1.4.0"
  puts colorize_lightblue("This is a universal dev env (version #{this_version})")
  # Skip version check if not on master (prevents infinite loops if you're in a branch that isn't up to date with the latest release code yet)
  current_branch = `git -C #{root_loc} rev-parse --abbrev-ref HEAD`.strip
  if current_branch == "master"
    self_update(root_loc, this_version)
  else
    puts colorize_yellow("*******************************************************")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("**                     WARNING!                      **")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("**         YOU ARE NOT ON THE MASTER BRANCH          **")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("**            UPDATE CHECKING IS DISABLED            **")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("**          THERE MAY BE UNSTABLE FEATURES           **")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("**   IF YOU DON'T KNOW WHY YOU ARE ON THIS BRANCH    **")
    puts colorize_yellow("**          THEN YOU PROBABLY SHOULDN'T BE!          **")
    puts colorize_yellow("**                                                   **")
    puts colorize_yellow("*******************************************************")
    puts ""
    puts colorize_yellow("Continuing in 10 seconds (CTRL+C to quit)...")
    sleep(10)
  end
end

# Define the DEV_ENV_CONTEXT_FILE file name to store the users app_grouping choice
# As vagrant up can be run from any subdirectory, we must make sure it is stored alongside the Vagrantfile
DEV_ENV_CONTEXT_FILE = root_loc + "/.dev-env-context"

LOGGING_CHOICE_FILE = root_loc + "/.log-choice"

if ENV.has_key?('VM_MEMORY')
  vm_memory = ENV['VM_MEMORY'].to_i
else
  vm_memory = 4096
end

Vagrant.configure(2) do |config|
  config.vm.box              = "landregistry/centos"
  config.vm.box_version      = "0.5.0"
  config.vm.box_check_update = false

  # Configure cached packages to be shared between instances of the same base box.
 	# More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
  config.cache.scope       = :box
  # Make cachier only cache yum instead of rooting about trying to figure things out itself
  config.cache.auto_detect = false
  config.cache.enable :yum

  # If they have persisted with the persistent storage, initialise the config for it
  if File.exist?(docker_storage_location)
    config.persistent_storage.enabled = true
    config.persistent_storage.location = docker_storage_location
    config.persistent_storage.size = 50000
    config.persistent_storage.mountpoint = '/var/lib/docker'
  end

  # If provisioning (or upping for the first time)
  if !(['provision', '--provision'] & ARGV).empty? || !File.exist?(root_loc + "/.vagrant/machines/default/virtualbox/action_provision")
    puts colorize_yellow("Provision detected - resetting commodities amd logging choice")
    do_kernel_additions_updates = true  # So we can do kernel update below
    # Delete commodities list as all containers will need reprovisioning from scratch
    if File.exists?(root_loc + '/.commodities.yml')
      File.delete(root_loc + '/.commodities.yml')
    end
    # Allow them to make the logging choice again
    if File.exists?(LOGGING_CHOICE_FILE)
      File.delete(LOGGING_CHOICE_FILE)
    end
  elsif quick_reload
    # If we have quick-reloaded, also set this to true so we can do guest additions update after a kernel update
    do_kernel_additions_updates = true
  else
    do_kernel_additions_updates = false
  end

  # Only if vagrant up/resume do we want to create dev-env configuration
  if ['up', 'resume', 'reload'].include?(ARGV[0]) && quick_reload == false
    # Check if a DEV_ENV_CONTEXT_FILE exists, to prevent prompting for dev-env configuration choice on each vagrant up
    if File.exists?(DEV_ENV_CONTEXT_FILE)
      puts ""
      puts colorize_green("This dev env has been provisioned to run for the repo: #{File.read(DEV_ENV_CONTEXT_FILE)}")
    else
      print colorize_yellow("Please enter the url of your dev env repo (SSH): ")
      app_grouping = STDIN.gets.chomp
      File.open(DEV_ENV_CONTEXT_FILE, "w+") { |file| file.write(app_grouping) }
    end

    # Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
    puts colorize_lightblue("Retrieving custom configuration repo files:")
    if Dir.exists?(root_loc + '/dev-env-project')
      command_successful = system 'git', '-C', root_loc + '/dev-env-project', 'pull'
      new_project = false
    else
      command_successful = system 'git', 'clone', File.read(DEV_ENV_CONTEXT_FILE), root_loc + '/dev-env-project'
      new_project = true
    end

    # Error if git clone or pulling failed
    if command_successful == false
      puts colorize_red("Something went wrong when cloning/pulling the dev-env configuration project. Check your URL?")
      # If we were cloning from a new URL, it is possible the URL was wrong - reset everything so they're asked again next time
      if new_project == true
        File.delete(DEV_ENV_CONTEXT_FILE)
        if Dir.exists?(root_loc + '/dev-env-project')
          FileUtils.rm_r root_loc + '/dev-env-project'
        end
      end
      puts colorize_yellow("Continuing in 10 seconds (CTRL+C to quit)...")
      sleep(10)
    end

    # If they have made an ELK stack choice already, say so
    if File.exists?(LOGGING_CHOICE_FILE)
      puts ""
      if (File.read(LOGGING_CHOICE_FILE) == 'full')
        puts colorize_lightblue("This dev-env is running the full ELK stack. Increasing memory to #{vm_memory}mb")
      else
        puts colorize_yellow("This dev-env is not running the full ELK stack.")
      end
    else
      # Otherwise ask if they'd like to run the full ELK stack
      puts ""
      print colorize_yellow("Would you like to run the full ELK stack to store and view app logs? This is quite memory intensive, so I will add an extra 1.5gb of memory onto the configured amount (#{vm_memory}mb) if you say yes! Logs can always be found in /logs/log.txt. (y/n) ")
      confirm = STDIN.gets.chomp
      until confirm.upcase.start_with?('Y', 'N')
        print colorize_yellow("Would you like to run the full ELK stack to store and view app logs? This is quite memory intensive, so I will add an extra 1.5gb of memory onto the configured amount (#{vm_memory}mb) if you say yes! Logs can always be found in /logs/log.txt. (y/n) ")
        confirm = STDIN.gets.chomp
      end
      # Save their choice for future ups
      if confirm.upcase.start_with?('Y')
        File.open(LOGGING_CHOICE_FILE, "w+") { |file| file.write("full") }
      else
        File.open(LOGGING_CHOICE_FILE, "w+") { |file| file.write("lite") }
      end
    end

    # Call the ruby function to pull/clone all the apps found in dev-env-project/configuration.yml
    puts colorize_lightblue("Updating apps:")
    update_apps(root_loc)

    # Create a file called .commodities.yml with the list of commodities in it
    puts colorize_lightblue("Creating list of commodities")
    create_commodities_list(root_loc)

    # Download any external supporting files
    puts colorize_lightblue("Downloading supporting files")
    load_supporting_files(root_loc)
  end

  if ['up', 'resume', 'reload'].include?(ARGV[0])
    # Find the ports of the apps and commodities on the host and add port forwards for them
    create_port_forwards(root_loc, config)
  end

  # If they have made an ELK stack choice already, increase the memory use variable
  # We do it here instead of the bit above where we ask them, in case that bit doesn't get run.
  vm_memory += 1536 if File.read(LOGGING_CHOICE_FILE) == 'full'

  # In the event of user requesting a vagrant destroy
  config.trigger.before :destroy do
    # remove DEV_ENV_CONTEXT_FILE created on provisioning
    confirm = nil
    until ["Y", "y", "N", "n"].include?(confirm)
      confirm = ask colorize_yellow("Would you like to KEEP your custom dev-env configuration files? (y/n) ")
    end
    if confirm.upcase == "N"
      File.delete(DEV_ENV_CONTEXT_FILE)
      if Dir.exists?(root_loc + '/dev-env-project')
        FileUtils.rm_r root_loc + '/dev-env-project'
      end
    end
    # remove .commodities.yml created on provisioning
    if File.exists?(root_loc + '/.commodities.yml')
      File.delete(root_loc + '/.commodities.yml')
    end
    if File.exists?(root_loc + '/.docker-compose-file-list')
      File.delete(root_loc + '/.docker-compose-file-list')
    end
    if File.exists?(QUICK_RELOAD_FILE)
      File.delete(QUICK_RELOAD_FILE)
    end
    if File.exists?(LOGGING_CHOICE_FILE)
      File.delete(LOGGING_CHOICE_FILE)
    end
  end

  # After a destroy, try to get rid of the peristant storage file since we don't want to use it any more. Causes problems with multiple dev envs and random plugin breakage.
  config.trigger.after :destroy do
    if File.exist?(docker_storage_location)
      confirm = nil
      until ["Y", "y", "N", "n"].include?(confirm)
        confirm = ask colorize_yellow("Would you like to DELETE your docker persistent cache file? It is known to cause problems so we would like to phase it out - therefore if you choose to delete it, it will not be recreated in future. Note that if you have other dev-env instances that still use it, you should say no, else they will break! (y/n) ")
      end
      if confirm.upcase == "Y"
        File.delete(docker_storage_location)
      end
    end
  end

  # Run script to configure environment
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/provision-environment.sh"

  # Install docker and docker-compose
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/docker/install-docker.sh"

  # If the dev env configuration repo contains a script, provision it here
  # This should only be for temporary use during early app development - see the README for more info
  if File.exists?(root_loc + '/dev-env-project/environment.sh')
    config.vm.provision :shell, :inline => "source /vagrant/dev-env-project/environment.sh"
  end

  # Once the machine is fully configured and (re)started, run some more stuff like commodity initialisation/provisioning
  config.trigger.after [:up, :resume, :reload] do
    # We only want to do the kernel/additions if provisioning, but we can't do them AS provisions because the reboots
    # would then count as finishing provisioning. Instead we do it in this trigger, but check the var we set earlier
    if do_kernel_additions_updates
      # We want up to date kernel to ensure maximum compatibility with advanced docker features like overlayfs
      puts colorize_lightblue("Updating Linux Kernel")
      if system "vagrant ssh -c \"source /vagrant/scripts/guest/update-kernel.sh\""
        # If nonzero exit code, kernel must have updated
        puts colorize_yellow("Linux Kernel has been updated.")
        puts colorize_yellow("Please restart the machine (vagrant reload)")
        File.write(QUICK_RELOAD_FILE, "Hi")
        exit
      else
        puts colorize_green("Kernel is up to date")
      end

      # Before we start the heavy lifting, update guest additions if necessary.
      puts colorize_lightblue("Updating VirtualBox Guest Additions")
      if system "vagrant ssh -c \"source /vagrant/scripts/guest/setup-vboxguest.sh\""
        # If nonzero exit code, additions must have updated
        puts colorize_yellow("VirtualBox Guest Additions have been updated.")
        puts colorize_yellow("Please restart the machine (vagrant reload)")
        File.write(QUICK_RELOAD_FILE, "Hi")
        exit
      else
        puts colorize_green("VirtualBox Guest Additions is up to date")
      end
    end

    # Call the ruby function to create the docker compose file containing the apps and their commodities
    puts colorize_lightblue("Creating docker-compose")
    prepare_compose(root_loc)

    # Build and start all the containers
    if not system "vagrant ssh -c \"source /vagrant/scripts/guest/docker/docker-provision.sh\""
      puts colorize_red("Something went wrong when creating your Docker images or containers. Check the output above.")
      exit
    end

    # Check the apps for a postgres SQL snippet to add to the SQL that then gets run.
    # If you later modify .commodities to allow this to run again (e.g. if you've added new apps to your group),
    # you'll need to delete the postgres container and it's volume else you'll get errors.
    # Do a full vagrant provision, or just ssh in and do docker rm -v -f postgres
    provision_postgres(root_loc)
    # Alembic
    provision_alembic(root_loc)
    # Run app DB2 SQL statements
    provision_db2(root_loc)
    # Elasticsearch
    provision_elasticsearch(root_loc)
    # Nginx
    provision_nginx(root_loc)

    # The images were built and containers created earlier. Now that commodities are all provisioned, we can start the containers
    if File.size(root_loc + '/.docker-compose-file-list') != 0
      # Start ELK first to get it out the way before the big memory hit
      if is_commodity?(root_loc, "logging")
        puts colorize_lightblue("Starting ELK stack...")
        # Start the bits of ELK they have asked for
        if File.read(LOGGING_CHOICE_FILE) == 'lite'
          system "vagrant ssh -c \"docker-compose up --no-build -d --remove-orphans logstash\""
        else
          system "vagrant ssh -c \"docker-compose up --no-build -d --remove-orphans logstash elasticsearch-logs kibana\""
        end
      end
      puts colorize_lightblue("Starting containers...")
      system "vagrant ssh -c \"docker-compose up --no-build -d \""
    else
      puts colorize_yellow("No containers to start.")
    end


    # If the dev env configuration repo contains a script, run it here
    # This should only be for temporary use during early app development - see the README for more info
    if File.exists?(root_loc + '/dev-env-project/after-up.sh')
      system "vagrant ssh -c \"source /vagrant/dev-env-project/after-up.sh\""
    end

    puts colorize_green("All done, environment is ready for use")
  end

  config.vm.provider :virtualbox do |vb|
  # Set a random name to avoid a folder-already-exists error after a destroy/up (virtualbox often leaves the folder lying around)
    vb.name = "landregistry-development #{Time.now.to_f}"
    vb.customize ['modifyvm', :id, '--memory', vm_memory]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
    vb.customize ['modifyvm', :id, '--paravirtprovider', 'kvm']
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-interval", 10000]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-min-adjust", 100]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-on-restore", 1]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]
  end
end