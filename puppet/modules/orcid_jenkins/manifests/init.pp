class orcid_jenkins ($is_vagrant = false) {

  $jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'
  $jenkins_port   = '8383'
  $jenkins_user   = 'jenkins'
  $jenkins_group  = 'jenkins'
        
  exec { "install_jenkins_key":
    command => "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
  }
  
  exec { "install_jenkins_repo":
    command => "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'",
    require => Exec["install_jenkins_key"]
  }
  
  exec { "update_ubuntu_repos":
    command => "sudo apt-get update",
    require => Exec["install_jenkins_repo"]
  }
  
  package { "jenkins":
    #ensure => latest,
    #ensure => 1.639,
    #ensure => 2.25,
    ensure => installed,  
    require => Exec["update_ubuntu_repos"]
  }
  
  file { "/var/lib/jenkins":
    ensure  => directory,
    recurse => true,
    owner => jenkins,
    group => jenkins,
    require => Package["jenkins"]
  }

  file { "/var/cache/jenkins":
    ensure  => directory,
    recurse => true,
    owner => jenkins,
    group => jenkins,
    require   => File["/var/lib/jenkins"]
  }

  file { "/var/log/jenkins":
    ensure  => directory,
    recurse => true,
    owner => jenkins,
    group => jenkins,
    require   => File["/var/cache/jenkins"]
  }

  file { "/etc/apt/sources.list.d/jenkins.list":
    mode => 644,
    owner => root,
    group => root,    
    source => "puppet:///modules/orcid_jenkins/etc_apt_sources.list.d_jenkins.list",
    require => File["/var/log/jenkins"]
  }
  
  file { "/etc/default/jenkins":
    ensure        => file,
    path          => '/etc/default/jenkins',
    content       => template('orcid_jenkins/etc_default_jenkins.erb'),
    require       => File["/var/lib/jenkins/"]
  }
  
  # for new/fresh jenkins installation
  # remove /var/lib/jenkins/secrets/initialAdminPassword /var/lib/jenkins/secrets/initialAdminPasswordx  
  exec { "rm -f /var/lib/jenkins/secrets/initialAdminPassword":
    onlyif => 'test -f /var/lib/jenkins/secrets/initialAdminPassword'
  }

  # Vagrant puppet has issues starting a service vagrant         
  if $is_vagrant == true {
    service { "jenkins":
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/default/jenkins']
    }
  }
}
