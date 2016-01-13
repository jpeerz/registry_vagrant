class orcid_base::common_libs {

  # Every machine should have these packages and configuration files

  $packagelist = [
    "libcurl4-openssl-dev",
  ]

  package { $packagelist:
    ensure => installed
  }

}

