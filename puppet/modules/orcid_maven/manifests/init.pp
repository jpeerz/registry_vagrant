class orcid_maven {

  package { "maven2":
        ensure => 'absent',
  }

  package { "maven":
        ensure => 'latest',
  }

}

