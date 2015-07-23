class orcid_deployment {

  file { "/home/orcid_tomcat/bin/scripts":
    ensure  => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat/bin"],
  }
  
  file { "/home/orcid_tomcat/bin/scripts/deployment":
    ensure  => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat/bin/scripts"],
  }
  
  file { "/home/orcid_tomcat/bin/scripts/deployment/shared.py":
    ensure    => file,
    source  => "puppet:///modules/orcid_deployment/home/orcid_tomcat/bin/scripts/deployment/shared.py",
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat',
    require => File["/home/orcid_tomcat/bin/scripts"]
  }

  file { "/home/orcid_tomcat/bin/scripts/deployment/deploy-app.py":
    ensure    => file,
    source  => "puppet:///modules/orcid_deployment/home/orcid_tomcat/bin/scripts/deployment/deploy-app.py",
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat',
    require => File["/home/orcid_tomcat/bin/scripts"]
  }
  
  file { "/home/orcid_tomcat/bin/scripts/deployment/restart-tomcat.py":
    ensure    => file,
    source  => "puppet:///modules/orcid_deployment/home/orcid_tomcat/bin/scripts/deployment/restart-tomcat.py",
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat',
    require => File["/home/orcid_tomcat/bin/scripts"]
  }
  
}
