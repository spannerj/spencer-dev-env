# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure essential plugins are installed, otherwise force exit
unless Vagrant.has_plugin?("vagrant-triggers")
  abort("vagrant-triggers is not installed!\nRun...\n    vagrant plugin install vagrant-triggers\nand vagrant up again :)\n")
end

# Define the DEV_ENV_CONTEXT_FILE file name to store the users app_grouping choice
DEV_ENV_CONTEXT_FILE = ".dev-env-context"

Vagrant.configure(2) do |config|
  config.vm.box              = "landregistry/centos"
  config.vm.box_version      = "0.3.0"
  config.vm.box_check_update = false
  config.ssh.forward_agent = true

  # Check if a DEV_ENV_CONTEXT_FILE exists, to prevent prompting for app_grouping choice on each vagrant up
  if File.exists?(DEV_ENV_CONTEXT_FILE)
    print "This dev env has been provisioned to run for: #{File.read(DEV_ENV_CONTEXT_FILE)}\n"
  else
    print "What app-grouping do you want?:"
    app_grouping = STDIN.gets.chomp
    File.open(DEV_ENV_CONTEXT_FILE, "w+") { |file| file.write(app_grouping) }
    config.vm.provision :shell, :inline => "echo You have selected #{app_grouping};", :privileged => false
  end

  # In the event of user requesting a vagrant destroy, remove DEV_ENV_CONTEXT_FILE created on provisioning
  config.trigger.before :destroy do
    print "Dumping the DEV_ENV_CONTEXT_FILE before destroying the VM...\n"
    File.delete(DEV_ENV_CONTEXT_FILE)
  end

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
