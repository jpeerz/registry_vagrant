# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include tools

class { 'orcid_java': }

class {
   orcid_tomcat:
     local_password => '$6$ZHUQRrIW.9iTAJ0Z$9vyWYor7k6SwxWvra5osKjZyuqHN30tQQJJFsrbDQkwfN1z1eRG7LUJUK6krOIWlCLCR9G05tA5pXfS4CPsyO/',
     require => Class["orcid_java"],
}

