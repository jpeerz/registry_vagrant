class orcid_tomcat($orcid_config_file = 'file:///home/orcid_tomcat/git/ORCID-Source/orcid-persistence/src/main/resources/staging-persistence.properties', $tomcat_catalina_opts) {

  $tomcat_loc = '/home/orcid_tomcat/bin/tomcat'
  $tomcat_bin = "apache-tomcat-8.0.21"
  $tomcat_tar = "${tomcat_bin}.tar.gz"

  file { "/home/orcid_tomcat/webapps":
    ensure  => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat"],
  }

  file { "/home/orcid_tomcat/bin":
    ensure  => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat"],
  }

  # download the tgz file
  file { "/home/orcid_tomcat/$tomcat_tar":
    path   => "/home/orcid_tomcat/$tomcat_tar",
    source  => "puppet:///modules/orcid_tomcat/$tomcat_tar",
    require => File["/home/orcid_tomcat/bin"],
  }

  # untar the tarball at the desired location
  exec { "untar $tomcat_tar":
    command => "/bin/tar xzvf /home/orcid_tomcat/$tomcat_tar -C /home/orcid_tomcat/bin/. && chown -R orcid_tomcat /home/orcid_tomcat/bin/. && chgrp -R orcid_tomcat /home/orcid_tomcat/bin/. ",
    creates => "/home/orcid_tomcat/bin/$tomcat_bin",
    require => File["/home/orcid_tomcat/$tomcat_tar", "/home/orcid_tomcat/bin"],
    notify  => File["/home/orcid_tomcat/bin/tomcat"],
  }

  file { '/home/orcid_tomcat/bin/tomcat':
    ensure => 'link',
    target => "/home/orcid_tomcat/bin/${tomcat_bin}",
    owner => orcid_tomcat,
    group => orcid_tomcat,
    mode => 0744,
  }

  file { "/home/orcid_tomcat/bin/tomcat/bin/startup.sh":
    ensure    => file,
    path    => '/home/orcid_tomcat/bin/tomcat/bin/startup.sh',
    content    => template('orcid_tomcat/home/orcid_tomcat/bin/tomcat/bin/startup.sh.erb'),
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat',
    require => File["/home/orcid_tomcat/bin/tomcat"]
  }

  file { "/home/orcid_tomcat/bin/tomcat/conf/server.xml":
    ensure    => file,
    source  => "puppet:///modules/orcid_tomcat/home/orcid_tomcat/bin/tomcat/conf/server.xml",
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat',
    require => File["/home/orcid_tomcat/bin/tomcat"]
  }

  orcid_tomcat::orcid_tomcat_log4j { "web_log4j": }
  orcid_tomcat::orcid_tomcat_log4j { "pub_log4j": }
  orcid_tomcat::orcid_tomcat_log4j { "api_log4j": }
  orcid_tomcat::orcid_tomcat_log4j { "solr_log4j": }
  orcid_tomcat::orcid_tomcat_log4j { "scheduler_log4j": }
  orcid_tomcat::orcid_tomcat_log4j { "metrics_log4j": }


  file { ["/home/orcid_tomcat/git"]:
    ensure => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat"],
    mode => "0775",
  }


  file { ["/home/orcid_tomcat/data", "/home/orcid_tomcat/data/solr",
    "/home/orcid_tomcat/conf"]:
    ensure => directory,
    owner => orcid_tomcat,
    group => orcid_tomcat,
    require => File["/home/orcid_tomcat"],
    mode => "0700",
  }

  exec { "git clone ORCID-Source":
    command => "sudo -u orcid_tomcat git clone --shared https://github.com/ORCID/ORCID-Source.git",
    cwd => "/home/orcid_tomcat/git",
    creates => "/home/orcid_tomcat/git/ORCID-Source",
    path   => "/usr/bin",
    timeout => "600",
    require => File["/home/orcid_tomcat/git"],
  }

  file { "/etc/init.d/tomcat":
    ensure => file,
    mode  => '0755',
    content => template('orcid_tomcat/etc/init.d/tomcat.erb'),
    owner  => "root",
    group  => "root"
  }

  file { [ "/etc/rc0.d/K20tomcat", "/etc/rc1.d/K20tomcat", "/etc/rc2.d/S20tomcat",
    "/etc/rc3.d/S20tomcat", "/etc/rc4.d/S20tomcat", "/etc/rc5.d/S20tomcat", "/etc/rc6.d/K20tomcat" ]:
    ensure  => link,
    target  => '/etc/init.d/tomcat',
    require => File["/etc/init.d/tomcat"],
  }
  
  file { "/home/orcid_tomcat/scripts/delete_old_logs/delete_old_logs.py":
    ensure    => file,
    source  => "puppet:///modules/orcid_tomcat/files/scripts/delete_old_logs/delete_old_logs.py",
    mode    => '0755',
    group    => 'orcid_tomcat',
    owner    => 'orcid_tomcat'
  }
  
  cron { log_cleaner:
	command => "python $orcid_old_logs_script -delete 45",
	user => orcid_tomcat
	hour => 0,
	minute => 0
  }

}
