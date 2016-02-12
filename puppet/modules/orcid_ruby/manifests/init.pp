class orcid_ruby {

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
    command => template("orcid_ruby/scripts/install_ruby.erb"),
    require => Package["wget"]
  }

  package { "bundler":
    ensure => latest,
    provider => gem,
    require  => Exec["ruby"],
  }

}
