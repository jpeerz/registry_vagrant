class orcid_python {


  exec { "python secure":
     environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
     command => "sudo apt-get -fy remove python; sudo apt-get -fy install python; sudo touch /usr/lib/python2.7/python_ssl.touched",
     returns => [0, 1],
     creates => "/usr/lib/python2.7/python_ssl.touched",
     require =>  Package["libssl-dev"],
  }

  $packages = [
    "libssl-dev", "python", "python-setuptools", "libffi-dev", "python2.7-dev",
    "python-dev", "libpq-dev", "python-openssl", "python-pip",
    "python-software-properties","python-psycopg2" 
  ]

  # install packages
  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }

  package { "pip":
    ensure => latest,
    provider => pip,
    require =>  Package["python-pip"],
  }

  $pip_packages = [
    "virtualenv", "python-gnupg", "pycurl", "filechunkio",
  ]

  package { $pip_packages:
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
