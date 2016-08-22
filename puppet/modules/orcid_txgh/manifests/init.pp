class orcid_txgh ($github_repo) {

  exec { "sudo_orcid_txgh":
    command => "sudo usermod -a -G sudo orcid_txgh",
    require => User["orcid_txgh"]
  }

  $packages = [
    "build-essential", "zlib1g-dev", "libssl-dev", "libreadline6-dev", "libyaml-dev"
  ]

  # install packages
  package { $packages:
    ensure => present,
    require  => Exec["apt-get update"]
  }

  exec { 'gpg_key':
    command => "sudo bash -l -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3'",
    require => [File["/home/orcid_txgh"], User["orcid_txgh"], Exec["sudo_orcid_txgh"]]
  }

  exec { 'rvm':
    command => "sudo bash -l -c 'curl -L https://get.rvm.io | bash -s stable'",
    creates => "/usr/local/rvm/bin/rvm",
    require => [Package['curl'], Exec['gpg_key']]
  }

  exec { 'ruby':
    command => "sudo bash -l -c '/usr/local/rvm/bin/rvm autolibs disable && /usr/local/rvm/bin/rvm install 2.1.5'",
    creates => "/usr/local/rvm/bin/rvm/ruby",
    require => Exec['rvm']
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
    command => "sudo unzip -o $txgh_loc/$txgh_zip -d $txgh_loc && chown orcid_txgh:orcid_txgh $txgh_loc/$txgh_rb",
    creates => "$txgh_loc/$txgh_rb",
    require => File["/home/orcid_txgh/$txgh_zip"]
  }

   # download the .ruby-version file
  file {".ruby-version":
    path   => "$txgh_loc/$txgh_rb/.ruby-version",
    source  => "puppet:///modules/orcid_txgh/.ruby-version",
    require => Exec["unzip $txgh_zip"]
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

  exec { "bundler":
    command => "bash -l -c 'su - orcid_txgh && cd /home/orcid_txgh/txgh-master && gem install bundler && bundle install'",
    require => [Exec["tx.config"], File[".ruby-version"]]
  }

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

  #exec { "rackup":
    #command => "bash -l -c 'su - orcid_txgh && cd /home/orcid_txgh/txgh-master && nohup rackup -o 0.0.0.0 > $(date +%m-%d-%Y)_txgh.log&'",
    #require => Exec["bundler"]
  #}

  file { "/etc/init.d/txgh":
    ensure => file,
    mode  => '0755',
    content => template('orcid_txgh/etc/init.d/txgh.erb'),
    owner  => "root",
    group  => "root",
    require => Exec["bundler"]
  }

  file { [ "/etc/rc0.d/K20txgh", "/etc/rc1.d/K20txgh", "/etc/rc2.d/S20txgh",
    "/etc/rc3.d/S20txgh", "/etc/rc4.d/S20txgh", "/etc/rc5.d/S20txgh", "/etc/rc6.d/K20txgh" ]:
    ensure  => link,
    target  => '/etc/init.d/txgh',
    require => File["/etc/init.d/txgh"]
  }

  service { 'txgh':
    ensure => 'running',
    enable => 'true',
    require => File["/etc/init.d/txgh"]
  }


}
