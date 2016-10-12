class orcid_base::postgresql_95 {
  
  $pg_package_name = "postgresql-9.5"  
  
  exec { "pg_install_apt_key":
    onlyif  => "test $(apt-key list | grep postgresql | wc -l) -eq 0",
    command => "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
  }
  
  file { "/etc/apt/sources.list.d/pgdg.list":
    ensure  => file,
    replace => no,
    content => "deb http://apt.postgresql.org/pub/repos/apt/ DISTROCODENAME-pgdg main",
    require => Exec['pg_install_apt_key']
  }
  
  exec { "pg_upgate_codename":
    onlyif  => "test $(grep $(lsb_release -cs) /etc/apt/sources.list.d/pgdg.list | wc -l) -eq 0",
    command => "sed -i s/DISTROCODENAME/$(lsb_release -cs)/g /etc/apt/sources.list.d/pgdg.list",
    require => File["/etc/apt/sources.list.d/pgdg.list"]
  }
  
  exec { "pg_upgate_ubuntu_packages_db":
    creates => "/usr/bin/psql",
    command => "sudo apt-get update 2>&1 > /dev/null",
    require => Exec['pg_upgate_codename']
  }
  
  package{$pg_package_name: 
    ensure  => installed,
    require => Exec['pg_upgate_ubuntu_packages_db']
  }

}
