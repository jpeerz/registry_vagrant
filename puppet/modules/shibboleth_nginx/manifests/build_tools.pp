class shibboleth_nginx::build_tools {

  $packages = [ "build-essential", "ubuntu-dev-tools" ]
  package { $packages :
        ensure => installed,
        require => [Exec["apt-get update"],Package["git"]]
  }

}
