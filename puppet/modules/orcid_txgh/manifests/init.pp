class orcid_txgh {

  $packages = [
    "build-essential", "zlib1g-dev", "libssl-dev", "libreadline6-dev", "libyaml-dev"
  ]


  # install packages
  package { $packages:
    ensure => present,
    require  => Exec["apt-get update"]
  }

  exec { "ruby":
    environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
    command => template("orcid_txgh/scripts/install_ruby.erb"),
    require => Package["wget"]
  }

  exec { "bundler":
    environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
    provider => shell,
    command => template("orcid_txgh/scripts/install_bundler.erb"),
    require => Exec["ruby"]
  }

}
