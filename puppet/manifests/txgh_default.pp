# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include orcid_base::baseapps
include orcid_base::common_libs
#include orcid_txgh

class {
  orcid_txgh:
    github_repo => 'ORCID/txgh_test',
}

user { "orcid_txgh":
  ensure  => present,
  uid  => '7013',
  shell  => '/bin/bash',
  home  => '/home/orcid_txgh',
  managehome => true,
  password => 'd9hliCDStS+VyAmWAZuCu4xnSRDsHIEE/Ve3/BzcToxp4tJDMxcn+CoJxtQl2+MZS1Lhp+jTLtqviDP1NbqpX2IOE9xapZHVUi8AWOjD',
}

file { "/home/orcid_txgh":
  ensure  => directory,
  owner => orcid_txgh,
  group => orcid_txgh,
  require => User["orcid_txgh"],
}
