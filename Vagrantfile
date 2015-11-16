Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
     #v.gui = true
     v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
     v.memory = 4000
     v.cpus = 4
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    if [ $(dpkg-query -s puppet | grep -c "3.8.1-1puppetlabs1") -eq 0 ];
      then
        sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
        sudo dpkg -i puppetlabs-release-trusty.deb
        sudo apt-get update;
        sudo apt-get -q -y --force-yes install puppet=3.8.1-1puppetlabs1 puppet-common=3.8.1-1puppetlabs1;
        sudo apt-mark -q hold puppet puppet-common;
    fi;
  SHELL

  # Install the puppet jenkins package we need
  config.vm.provision :shell do |shell|
	shell.inline = "mkdir -p /etc/puppet/modules;
                  puppet module install rtyler-jenkins"
	end
  
  # Enable the Puppet provisioner, with will look in manifests
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "puppet/modules"
    puppet.facter = {
      'orcid_config_file' => ENV['ORCID_CONFIG_FILE'],
    }
    puppet.options = "--verbose --debug"
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # Forward guest port to host portand name mapping
  #config.vm.network :forwarded_port, guest: 80, host: 80
  config.vm.network :forwarded_port, guest: 8080, host: 8080


  config.vm.synced_folder "git", "/home/orcid_tomcat/git", 
     mount_options: ["uid=7006,gid=7006,dmode=775,fmode=664"],
     create: true


end
