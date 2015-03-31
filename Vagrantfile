# but build to match our production
Vagrant.configure("2") do |config|

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

#  config.vm.synced_folder "git", "/home/orcid_tomcat/git", 
#     owner: "orcid_tomcat",
#     group: "orcid_tomcat",
#     mount_options: ["dmode=775,fmode=664"]

end
