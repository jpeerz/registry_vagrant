# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include tools

user { "orcid_tomcat":
  ensure  => present,
  uid  => '7006',
  shell  => '/bin/bash',
  home  => '/home/orcid_tomcat',
  managehome => true,
  password => '$6$ZHUQRrIW.9iTAJ0Z$9vyWYor7k6SwxWvra5osKjZyuqHN30tQQJJFsrbDQkwfN1z1eRG7LUJUK6krOIWlCLCR9G05tA5pXfS4CPsyO/',
}

class { 'orcid_java': }

class {
   orcid_tomcat:
     require => [Class["orcid_java"],User["orcid_tomcat"]]
}

