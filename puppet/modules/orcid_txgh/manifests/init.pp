class orcid_txgh ($github_repo) {

  $packages = [
    "build-essential", "zlib1g-dev", "libssl-dev", "libreadline6-dev", "libyaml-dev"
  ]

  # install packages
  package { $packages:
    ensure => present,
    require  => Exec["apt-get update"]
  }

  exec { "rvm":
    command => "sudo apt-add-repository ppa:rael-gc/rvm && sudo apt-get update && sudo apt-get -y install rvm && sudo usermod -a -G rvm orcid_txgh",
  }

  exec { "ruby":
    user => "orcid_txgh",
    command => "bash --login -c 'rvm install 2.1.5'",
    require => Exec["rvm"]
  }

  $txgh_loc = '/home/orcid_txgh'
  $txgh_rb = "txgh-master"
  $txgh_zip = "${txgh_rb}.zip"


  # download the txgh-master zip
  file { "/home/orcid_txgh/$txgh_zip":
    path   => "$txgh_loc/$txgh_zip",
    source  => "puppet:///modules/orcid_txgh/$txgh_zip",
    require => Exec["ruby"]
  }

  # unzip txgh-master zip at the desired location
  exec { "unzip $txgh_zip":
    command => "sudo unzip -o $txgh_loc/$txgh_zip -d $txgh_loc",
    creates => "$txgh_loc/$txgh_rb",
    require => File["/home/orcid_txgh/$txgh_zip"]
  }

  # download the txgh.yml configuration file
  file {"txgh.yml":
    path   => "$txgh_loc/$txgh_rb/config/txgh.yml",
    source  => "puppet:///modules/orcid_txgh/txgh.yml",
    require => Exec["unzip $txgh_zip"]
  }


  # download the .tx/config configuration file
  exec { "tx.config":
    environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
    provider => shell,
    command => template("orcid_txgh/scripts/download_tx_config.erb"),
    require => File["txgh.yml"]
  }

  #exec { "bundler":
    #environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
    #provider => shell,
    #command => template("orcid_txgh/scripts/install_bundler.erb"),
    #require => Exec["tx.config"]
  #}

  $ngrok_loc = '/home/orcid_txgh'
  $ngrok_bin = "ngrok-stable-linux-amd64"
  $ngrok_zip = "${ngrok_bin}.zip"


  # download the ngrok zip
  file { "/home/orcid_txgh/$ngrok_zip":
    path   => "/home/orcid_txgh/$ngrok_zip",
    source  => "puppet:///modules/orcid_txgh/$ngrok_zip",
  }

  # unzip ngrok zip at the desired location
  exec { "unzip $ngrok_zip":
    command => "sudo unzip -o $ngrok_loc/$ngrok_zip",
    creates => "/$ngrok_loc/$ngrok_bin",
    #require => Exec["bundler"]
  }



}
