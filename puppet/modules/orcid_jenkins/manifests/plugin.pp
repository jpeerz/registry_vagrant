# java -jar ~/bin/jenkins-cli.jar -s http://192.168.25.37:8090/ -i ~/.ssh/id_rsa install-plugin ./$title.hpi -deploy
define orcid_jenkins::plugin_local(
  $plugins_dir = "/var/lib/jenkins/plugins",
  $jenkins_cli = "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/"
) {
  $plugin_folder = "$plugins_dir/$title"
  exec { "download-$title":
    command => "rsync -avz rsync://rsync.osuosl.org/jenkins/plugins/$title/latest /tmp/",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",    
  }
  exec { $title:
    require  => Exec["download-$title"],
    command  => "$jenkins_cli -i /var/lib/jenkins/.ssh/id_rsa_script install-plugin ${title}.hpi -deploy", #  >> /vagrant/plugins_installed.log
    onlyif   => "test ! -d $plugin_folder",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/"
  }
}

define orcid_jenkins::plugin(
    $plugins_dir = "/var/lib/jenkins/plugins",
    $jenkins_cli = "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/"
) {
    $plugin_folder = "$plugins_dir/$title"
    exec { $title:
        require  => Exec["download-$title"],
        command  => "$jenkins_cli -i /var/lib/jenkins/.ssh/id_rsa_script install-plugin $title -deploy",
        onlyif   => "test ! -d $plugin_folder && test -f /var/lib/jenkins/.ssh/id_rsa_jenkins",
        provider => 'shell',
        path     => ["/bin","/usr/bin"],
        cwd      => "/var/lib/jenkins/"
    }
}