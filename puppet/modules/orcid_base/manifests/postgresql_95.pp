class orcid_base::postgresql_95 {
  
  $pg_package_name = "postgresql-9.5"

  if ! defined(File['/etc/postgresql']) {
    
    notify { "Installing Postgres...":}
    
    exec { "pg_install_apt_key":
      command => "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -",
      #require => [Package['wget'],Package['ca-certificates']]
    }
    
    file { "/etc/apt/sources.list.d/pgdg.list":
      ensure  => file,
      content => "deb http://apt.postgresql.org/pub/repos/apt/ DISTROCODENAME-pgdg main",
      require => Exec['pg_install_apt_key']
    }
    
    exec { "pg_upgate_codename":
      command => "sed -i s/DISTROCODENAME/$(lsb_release -cs)/g /etc/apt/sources.list.d/pgdg.list",
      require => File["/etc/apt/sources.list.d/pgdg.list"]
    }
    
    exec { "pg_upgate_ubuntu_packages_db":
      command => "sudo apt-get update 2>&1 > /dev/null",
      require => Exec['pg_upgate_codename']
    }
    
    package{$pg_package_name: 
      ensure  => installed,
      require => Exec['pg_upgate_ubuntu_packages_db']
    }
    
    file { "/etc/postgresql/9.5/main/pg_hba.conf":
      ensure  => file,
      backup  => true,
      owner   => 'postgres',
      group   => 'postgres',
      mode    => '0440',
      source  => 'puppet:///modules/orcid_base/etc_postgresql_95_pg_hba.conf',
      require => Package[$pg_package_name],
    }
    
  } else {
    notify { "PostgreSQL is already installed!":}
  }

}
