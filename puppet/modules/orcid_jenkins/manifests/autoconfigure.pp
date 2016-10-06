class orcid_jenkins::autoconfigure {
  $plugins = [
    "pam-auth",
    "plain-credentials",
    "workflow-step-api",
    "translation",
    "javadoc",
    "ssh-credentials",
    "ant",
    "external-monitor-job",
    "github-api",
    "credentials",
    "ldap",
    "ssh-slaves",
    "ghprb",
    "subversion",
    "rebuild",
    "script-security",
    "matrix-project",
    "matrix-auth",
    "maven-plugin",
    "ssh-agent",
    "antisamy-markup-formatter",
    "git",
    "cvs",
    "mailer",
    "git-client",
    "github",
    "slack",
    "scm-api",
    "junit",
    "windows-slaves"
  ]
  
  $jobs = [
    "ORCID-push_checker"
  ]
  $jenkins_port   = '8383'
  $jenkins_user   = 'jenkins'
  $jenkins_group  = 'jenkins'  
        
  exec { "download_jenkins_cli":
    onlyif   => "test ! -f /var/lib/jenkins/jenkins-cli.jar",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => "wget -O /var/lib/jenkins/jenkins-cli.jar http://localhost:8383/jnlpJars/jenkins-cli.jar"
  }
  
  file { "/var/lib/jenkins/jenkins-cli.jar":
    ensure  => present,
    owner   => jenkins,
    group   => jenkins,
    require => Exec['download_jenkins_cli']
  }
  
  exec { "disable_jenkins_security":
    require  => File["/var/lib/jenkins/"],
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => "sed -i 's/FullControlOnceLoggedInAuthorizationStrategy/hudson.security.AuthorizationStrategy\$Unsecured/' /var/lib/jenkins/config.xml"
  }
  
  # and use /modules/orcid_jenkins/files/var/lib/jenkins/bootstrap_config.xml <slaveAgentPort>49187</slaveAgentPort>
  # to accept CLI calls
  # create tmp user
  # echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("test", "test1234")' |  java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/ groovy =  
    
  file { "/etc/default/jenkins_config":
    replace       => true,
    ensure        => file,
    path          => '/etc/default/jenkins_config',
    content       => template('orcid_jenkins/etc/default/jenkins_config.erb'),
    notify        => Exec['go_config_mode']
  }

  exec { "go_config_mode":
    require  => Exec['disable_jenkins_security'],
    provider => 'shell',
    path     => ["/bin","/usr/bin"],    
    command  => 'cp -Rfa /etc/default/jenkins /etc/default/jenkins_prod && \cp -Rfa /etc/default/jenkins_config /etc/default/jenkins',
    notify   => Service['jenkins']
  }
      
  orcid_jenkins::job { "test": }  
  
  exec { "enable_jenkins_security":
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => "sed -i 's/hudson.security.AuthorizationStrategy\$Unsecured/FullControlOnceLoggedInAuthorizationStrategy/' /var/lib/jenkins/config.xml"
  }
  

}