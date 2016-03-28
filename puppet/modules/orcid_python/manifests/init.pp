class orcid_python {

  exec { "python secure":
     environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
     command => "sudo apt-get -fy remove python; 
sudo apt-get -fy install libssl-dev python-setuptools libffi-dev python2.7-dev python-dev libpq-dev python-openssl python-pip python-software-properties python-psycopg2 python; 
sudo touch /usr/lib/python2.7/python_ssl.touched",
     returns => [0, 1],
     creates => "/usr/lib/python2.7/python_ssl.touched",
     require =>  [Package["libcurl4-openssl-dev"]],
     before => Package['pip'],
  }

  package { "pip":
    ensure => latest,
    provider => pip,
    require =>  [Exec["python secure"]],
  }

  $pip_packages = [
    "virtualenv", "python-gnupg", "pycurl", "filechunkio", "requests[security]", "certifi",
    "wrapt", "pyrax", "netifaces", "monotonic", "boto", "argparse", "GitPython"
  ]

  package { $pip_packages:
    ensure => latest,
    provider => pip,
    require =>  [Package["pip"]],
  }

}
