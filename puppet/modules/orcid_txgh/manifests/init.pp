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

  $txgh_loc = '/home/$USER'
  $txgh_rb = "txgh-master"
  $txgh_zip = "${txgh_rb}.zip"


  # download the txgh-master zip
  file { "/home/$USER/$txgh_zip":
    path   => "/home/$USER/$txgh_zip",
    source  => "puppet:///modules/orcid_txgh/$txgh_zip",
  }

  # unzip txgh-master zip at the desired location
  exec { "unzip $txgh_zip":
    command => "unzip $txgh_loc/$txgh_zip",
    creates => "/$txgh_loc/$txgh_rb",
    require => Exec["ruby"]
  }

  exec { "bundler":
    environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
    provider => shell,
    command => template("orcid_txgh/scripts/install_bundler.erb"),
    require => Exec["unzip $txgh_zip"]
  }

  $ngrok_loc = '/home/$USER'
  $ngrok_bin = "ngrok-stable-linux-amd64"
  $ngrok_zip = "${ngrok_bin}.zip"


  # download the ngrok zip
  file { "/home/$USER/$ngrok_zip":
    path   => "/home/$USER/$ngrok_zip",
    source  => "puppet:///modules/orcid_txgh/$ngrok_zip",
  }

  # unzip ngrok zip at the desired location
  exec { "unzip $ngrok_zip":
    command => "unzip $ngrok_loc/$ngrok_zip",
    creates => "/$ngrok_loc/$ngrok_bin",
    require => Exec["bundler"]
  }

}
