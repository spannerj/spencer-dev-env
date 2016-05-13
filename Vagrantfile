# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure essential plugins are installed
require File.dirname(__FILE__)+"/scripts/dependency_manager"
require File.dirname(__FILE__)+"/scripts/update_apps"
require File.dirname(__FILE__)+"/scripts/utilities"
# If plugins have been installed, rerun the original vagrant command and abandon this one
if not check_plugins ["vagrant-cachier", "vagrant-triggers", "vagrant-reload"]
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

  #Only if vagrant up/reload/resume do want to create dev-env configuration
  if ['up', 'reload', 'resume'].include? ARGV[0]
    # Check if a DEV_ENV_CONTEXT_FILE exists, to prevent prompting for dev-env configuration choice on each vagrant up
    if File.exists?(DEV_ENV_CONTEXT_FILE)
      puts colorize_lightblue("This dev env has been provisioned to run for the repo: #{File.read(DEV_ENV_CONTEXT_FILE)}")
     else
      puts colorize_lightblue("This is a universal dev env.")
      print colorize_yellow("Please enter the url of your dev env repo: ")
      app_grouping = STDIN.gets.chomp
      File.open(DEV_ENV_CONTEXT_FILE, "w+") { |file| file.write(app_grouping) }
    end

    #Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
    puts colorize_lightblue("Retrieving latest configuration repo files:")
    if Dir.exists?(File.dirname(__FILE__) + '/dev-env-project')
      command_successful = system 'git', '-C', File.dirname(__FILE__) + '/dev-env-project', 'pull'
    else
      command_successful = system 'git', 'clone', File.read(DEV_ENV_CONTEXT_FILE), File.dirname(__FILE__) + '/dev-env-project'
    end

    #Error if git clone or pulling failed
    if command_successful == false
      puts colorize_red("Something went wrong when cloning/pulling the dev-env configuration project")
      exit 1
    end

    #Call the ruby function to pull/clone all the apps found in dev-env-project/configuration.yml
    puts colorize_lightblue("Updating apps:")
    update_apps(File.dirname(__FILE__))
  end

  # In the event of user requesting a vagrant destroy, remove DEV_ENV_CONTEXT_FILE created on provisioning
  config.trigger.before :destroy do
    puts "Dumping the DEV_ENV_CONTEXT_FILE before destroying the VM..."
    File.delete(DEV_ENV_CONTEXT_FILE)
  end

  # Run script to configure environment
  config.vm.provision "shell" do |s|
      app_grouping = File.read(DEV_ENV_CONTEXT_FILE)
      s.inline = "source /vagrant/scripts/provision-environment.sh"
      s.args = [app_grouping]
  end

  # Update Virtualbox Guest Additions
  config.vm.provision :shell, :inline => "source /vagrant/scripts/setup-vboxguest.sh"

  #Reload VM after Guest Additions have been installed, so that shared folders work
  config.vm.provision :reload

  config.vm.provider :virtualbox do |vb|
  # Set a random name to avoid a folder-already-exists error after a destroy/up (virtualbox often leaves the folder lying around)
    vb.name = "landregistry-development #{Time.now.to_f}"
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 4096]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
    vb.customize ['modifyvm', :id, '--paravirtprovider', 'kvm']
  end
end
