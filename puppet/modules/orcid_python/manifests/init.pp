class orcid_python {

  package { "python":
    ensure => installed,
  }

  package { "python-setuptools":
    ensure => installed,
  }

  package { "python-pip":
    ensure => installed,
  }
  
  package { "pip":
    ensure => latest,
    provider => pip,
    require =>  Package["python-pip"],
  }

  package { "python-dev":
    ensure => installed,
  }
  
  package { "python-gnupg":
    ensure => latest,
    provider => pip,
    require =>  Package["pip"],
  }

  package { "filechunkio":
    ensure => latest,
    provider => pip,
    require =>  Package["pip"],
  }

  exec { 'pyrax install':
    command => 'sudo pip install --upgrade  wrapt pyrax netifaces monotonic;
sudo easy_install --upgrade GitPython;
touch /usr/local/lib/pryax_puppet_installed;
',
    creates => '/usr/local/lib/pryax_puppet_installed',
    require => [Package["pip"]]
  }

}