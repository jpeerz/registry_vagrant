Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
     #v.gui = true
     v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
     v.memory = 4000
     #v.cpus = 2
  end

  # Enable the Puppet provisioner, with will look in manifests
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "puppet/modules"
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # Forward guest port to host portand name mapping
  config.vm.network :forwarded_port, guest: 80, host: 80
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  config.vm.synced_folder "git", "/home/orcid_tomcat/git", 
     mount_options: ["uid=7006,gid=7006,dmode=775,fmode=664"]


end
