Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello"

  config.vm.define "tomcat", autostart: false do |tomcat|
    tomcat.vm.provider "virtualbox" do |v|
       #v.gui = true
       v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
       v.memory = 4000
       v.cpus = 4
    end

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    tomcat.vm.provision "shell", inline: <<-SHELL
      if [ $(dpkg-query -s puppet | grep -c "3.8.1-1puppetlabs1") -eq 0 ];
        then
          sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
          sudo dpkg -i puppetlabs-release-trusty.deb
          sudo apt-get update;
          sudo apt-get -q -y --force-yes install puppet=3.8.1-1puppetlabs1 puppet-common=3.8.1-1puppetlabs1;
          sudo apt-mark -q hold puppet puppet-common;
      fi;
    SHELL

    # Enable the Puppet provisioner, with will look in manifests
    tomcat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "tomcat_default.pp"
      puppet.module_path = "puppet/modules"
      puppet.facter = {
        'orcid_config_file' => ENV['ORCID_CONFIG_FILE'],
      }
      puppet.options = "--verbose --debug"
    end

    # Every Vagrant virtual environment requires a box to build off of.
    tomcat.vm.box = "ubuntu/trusty64"

    # Forward guest port to host portand name mapping
    tomcat.vm.network :forwarded_port, guest: 8080, host: 8080


    tomcat.vm.synced_folder "git", "/home/orcid_tomcat/git", 
       mount_options: ["uid=7006,gid=7006,dmode=775,fmode=664"],
       create: true
  end

end
