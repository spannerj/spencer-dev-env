# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |node|
  node.vm.box              = "landregistry/centos"
  node.vm.box_version      = "0.3.0"
  node.vm.box_check_update = false
  node.ssh.forward_agent = true


  #  Prevent annoying "stdin: is not a tty" errors from displaying during 'vagrant up'
  # See https://github.com/mitchellh/vagrant/issues/1673#issuecomment-168205206
  node.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  node.vm.provider :virtualbox do |vb|
  # Set a random name to avoid a folder-already-exists error after a destroy/up (virtualbox often leaves the folder lying around)
    vb.name = "landregistry-development #{Time.now.to_f}"
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 4096]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
    vb.customize ['modifyvm', :id, '--paravirtprovider', 'kvm']
  end
end
