class orcid_python {

  $packages = [
    "libssl-dev", "python", "python-setuptools", "libffi-dev", "python2.7-dev",
    "python-dev", "libpq-dev", "python-openssl", "python-pip",
    "python-software-properties","python-psycopg2"
  ]

  exec { "python secure":
     environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
     command => "sudo apt-get -fy remove python; sudo apt-get -fy install python; sudo ;sudo touch /usr/lib/python2.7/python_ssl.touched",
     returns => [0, 1],
     creates => "/usr/lib/python2.7/python_ssl.touched",
     require =>  [Package[$packages],Package["libcurl4-openssl-dev"]],
  }

  # install packages
  package { $packages:
    ensure => present,
    require  => Exec["apt-get update"]
  }

  package { "pip":
    ensure => latest,
    provider => pip,
    require =>  Package["python-pip"],
  }

  $pip_packages = [
    "virtualenv", "python-gnupg", "pycurl", "filechunkio", "requests[security]", "certifi", 
    "wrapt", "pyrax", "netifaces", "monotonic", "GitPython"
  ]

  package { $pip_packages:
    ensure => latest,
    provider => pip,
    require =>  Package["pip"],
  }


}
