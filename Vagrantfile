# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure essential plugins are installed
require_relative 'scripts/host/plugin_manager'
require_relative 'scripts/host/update_apps'
require_relative 'scripts/host/utilities'
require_relative 'scripts/host/docker_compose'
require_relative 'scripts/host/expose_ports'
require_relative 'scripts/host/postgres_provision'
require_relative 'scripts/host/alembic_provision'
require_relative 'scripts/host/db2_provision'
require_relative 'scripts/host/commodities'
require_relative 'scripts/host/elasticsearch_provision'
require 'fileutils'
require "rubygems"
require "json"
require "net/http"
require "uri"

# If plugins have been installed, rerun the original vagrant command and abandon this one
if not check_plugins ["vagrant-cachier", "vagrant-triggers", "vagrant-reload", "vagrant-persistent-storage"]
  exec "vagrant #{ARGV.join(' ')}" unless ARGV[0] == 'plugin'
end

# If user is doing a reload, the raw script commands like updating app repos will be done before the machine halts.
# So stop the apps now, just so they don't try to reload and run any new code.
if ['reload'].include? ARGV[0] 
  puts colorize_lightblue('Stopping apps')
  system "vagrant ssh -c \"docker-compose stop\""
end

# Only if vagrant up/resume do we want to check for update
if ['up', 'resume', 'reload'].include? ARGV[0]
  this_version = "1.1.0"
  puts colorize_lightblue("This is a universal dev env (version #{this_version})")
  # Check for new version (using a snippet)
  versioncheck_uri = URI.parse("http://192.168.249.38/common/dev-env/snippets/12/raw")
  http = Net::HTTP.new(versioncheck_uri.host, versioncheck_uri.port)
  request = Net::HTTP::Get.new(versioncheck_uri.request_uri)
  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      latest_version = result["version"]
      if Gem::Version.new(latest_version) > Gem::Version.new(this_version)
        puts colorize_yellow("A new version is available - v#{latest_version}")
        puts colorize_yellow("Changes:")
        result["changes"].each { |change| puts colorize_yellow("  " + change) }
        puts colorize_yellow("Updating in 5 seconds...")
        if not system 'git', '-C', File.dirname(__FILE__), 'pull'
          puts colorize_yellow("There was an error retrieving the new dev-env. Sorry. I'll just get on with starting the machine...")
        else
          exec "vagrant #{ARGV.join(' ')}"
        end
      else
        puts colorize_green("This is the latest version.")
      end
    else
      puts colorize_yellow("There was an error retrieving the current dev-env version (is AWS GitLab down?). I'll just get on with starting the machine...")
    end
  rescue StandardError => e
    puts e
    puts colorize_yellow("There was an error retrieving the current dev-env version (is AWS GitLab down?). I'll just get on with starting the machine...")
  end
end

# Define the DEV_ENV_CONTEXT_FILE file name to store the users app_grouping choice
# As vagrant up can be run from any subdirectory, we must make sure it is stored alongside the Vagrantfile
DEV_ENV_CONTEXT_FILE = File.dirname(__FILE__) + "/.dev-env-context"

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

  # Docker persistent storage (cachier can't cope)
  config.persistent_storage.enabled = true
  # Put the cache file in the vagrant cache directory - but got to find out where that is first!
  if ENV.has_key?('VAGRANT_HOME') # Overidden by user
    config.persistent_storage.location = ENV['VAGRANT_HOME'] + "/cache/docker_storage.vdi"
  elsif ENV.has_key?('USERPROFILE') # Windows default
    config.persistent_storage.location = ENV['USERPROFILE'] + "/.vagrant.d/cache/docker_storage.vdi"
  elsif ENV.has_key?('HOME') # Linux/OSX default
    config.persistent_storage.location = ENV['HOME'] + "/.vagrant.d/cache/docker_storage.vdi"
  else # Last resort
    config.persistent_storage.location = "~/.vagrant.d/cache/docker_storage.vdi"
  end
  config.persistent_storage.size = 50000
  config.persistent_storage.mountpoint = '/var/lib/docker'

  # If provisioning, delete commodities list as all containers will need reprovisioning from scratch
  if !(['provision', '--provision'] & ARGV).empty?
    if File.exists?(File.dirname(__FILE__) + '/.commodities.yml')
      File.delete(File.dirname(__FILE__) + '/.commodities.yml')
    end
  end

  # Only if vagrant up/resume do we want to create dev-env configuration
  if ['up', 'resume', 'reload'].include? ARGV[0]
    # Check if a DEV_ENV_CONTEXT_FILE exists, to prevent prompting for dev-env configuration choice on each vagrant up
    if File.exists?(DEV_ENV_CONTEXT_FILE)
      puts colorize_green("This dev env has been provisioned to run for the repo: #{File.read(DEV_ENV_CONTEXT_FILE)}")
    else
      print colorize_yellow("Please enter the url of your dev env repo (SSH): ")
      app_grouping = STDIN.gets.chomp
      File.open(DEV_ENV_CONTEXT_FILE, "w+") { |file| file.write(app_grouping) }
    end

    # Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
    puts colorize_lightblue("Retrieving custom configuration repo files:")
    if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
      command_successful = system 'git', '-C', File.dirname(__FILE__) + '/dev-env-project', 'pull'
      new_project = false
    else
      command_successful = system 'git', 'clone', File.read(DEV_ENV_CONTEXT_FILE), File.dirname(__FILE__) + '/dev-env-project'
      new_project = true
    end

    # Error if git clone or pulling failed
    if command_successful == false
      puts colorize_red("Something went wrong when cloning/pulling the dev-env configuration project. Check your URL?")
      # If we were cloning from a new URL, it is possible the URL was wrong - reset everything so they're asked again next time
      if new_project == true
        File.delete(DEV_ENV_CONTEXT_FILE)
        if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
          FileUtils.rm_r File.dirname(__FILE__) + '/dev-env-project'
        end
      end
      exit 1
    end

    # Call the ruby function to pull/clone all the apps found in dev-env-project/configuration.yml
    puts colorize_lightblue("Updating apps:")
    update_apps(File.dirname(__FILE__))

    # Create a file called .commodities.yml with the list of commodities in it
    puts colorize_lightblue("Creating list of commodities")
    create_commodities_list(File.dirname(__FILE__))

    # Call the ruby function to create the docker compose file containing the apps and their commodities
    puts colorize_lightblue("Creating docker-compose")
    prepare_compose(File.dirname(__FILE__))

    # Find the ports of the apps and commodities on the host and add port forwards for them
    create_port_forwards(File.dirname(__FILE__), config)
  end

  # In the event of user requesting a vagrant destroy
  config.trigger.before :destroy do
    # remove DEV_ENV_CONTEXT_FILE created on provisioning
    confirm = nil
    until ["Y", "y", "N", "n"].include?(confirm)
      confirm = ask colorize_yellow("Would you like to keep your custom dev-env configuration files? (y/n) ")
    end
    if confirm.upcase == "N"
      File.delete(DEV_ENV_CONTEXT_FILE)
      if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
        FileUtils.rm_r File.dirname(__FILE__) + '/dev-env-project'
      end
    end
    # remove .commodities.yml created on provisioning
    if File.exists?(File.dirname(__FILE__) + '/.commodities.yml')
      File.delete(File.dirname(__FILE__) + '/.commodities.yml')
    end
  end

  # Run script to configure environment
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/provision-environment.sh"

  # Install docker and docker-compose
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/docker/install-docker.sh"

  # Build and start all the containers
  config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/docker/docker-provision.sh", run: "always"

  # If the dev env configuration repo contains a script, provision it here
  # This should only be for temporary use during early app development - see the README for more info
  if File.exists?(File.dirname(__FILE__) + '/dev-env-project/environment.sh')
    config.vm.provision :shell, :inline => "source /vagrant/dev-env-project/environment.sh"
  end

  #### COMMENTING OUT GUEST ADDITIONS UPDATES START
  # Reason: the base box now has 5.0 level additions.
  # Also, the reboot step causes problems when doing a reload --provision now that we've had to remove the halt/up trick.

  # Update Virtualbox Guest Additions
  #config.vm.provision :shell, :inline => "source /vagrant/scripts/guest/setup-vboxguest.sh"

  # Reload VM after Guest Additions have been installed, so that shared folders work.
  # Always force reload last, after every provisioner has run, otherwise if a provisioner
  # is set to always run it will get run twice.
  #config.vm.provision :reload

   #### COMMENTING OUT GUEST ADDITIONS UPDATES END

  # Once the machine is fully configured and (re)started, run some more stuff like commodity initialisation/provisioning
  config.trigger.after [:up, :resume, :reload] do
    # Check the apps for a postgres SQL snippet to add to the SQL that then gets run.
    # If you later modify .commodities to allow this to run again (e.g. if you've added new apps to your group),
    # you'll need to delete the postgres container and it's volume else you'll get errors.
    # Do a full vagrant provision, or just ssh in and do docker rm -v -f postgres
    provision_postgres(File.dirname(__FILE__))
    # Alembic
    provision_alembic(File.dirname(__FILE__))
    # Run app DB2 SQL statements
    provision_db2(File.dirname(__FILE__))
    # Elasticsearch
    provision_elasticsearch(File.dirname(__FILE__))

    # The images were built and containers created earlier. Now that commodoties are all provisioned, we can start the containers
    if File.size(File.dirname(__FILE__) + '/.docker-compose-file-list') != 0
      puts colorize_lightblue("Starting containers")
      system "vagrant ssh -c \"docker-compose up --no-build -d \""
    else
      puts colorize_yellow("No containers to start.")
    end

    # If the dev env configuration repo contains a script, run it here
    # This should only be for temporary use during early app development - see the README for more info
    if File.exists?(File.dirname(__FILE__) + '/dev-env-project/after-up.sh')
      system "vagrant ssh -c \"source /vagrant/dev-env-project/after-up.sh\""
    end

    puts colorize_green("All done, environment is ready for use")
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
