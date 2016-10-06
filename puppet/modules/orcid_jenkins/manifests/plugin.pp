# java -jar ~/bin/jenkins-cli.jar -s http://192.168.25.37:8090/ -i ~/.ssh/id_rsa install-plugin ./$title.hpi -deploy
define orcid_jenkins::plugin($plugins_dir,$jenkins_cli="java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/") {
  $plugin = "$plugins_dir/$title"
  exec { "download-$title":
    command => "rsync -avz rsync://rsync.osuosl.org/jenkins/plugins/$title/latest/ /tmp/"
  }
  exec { $title:
    onlyif   => "test ! -d $plugin",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => "$jenkins_cli -i /var/lib/jenkins/.ssh/id_rsa_script install-plugin $title -deploy >> /vagrant/plugins_installed.log"
  }
}
