# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
class {
  orcid_base::baseapps:
    enable_google_authenticator => false
}

include orcid_base::common_libs

class {
   orcid_jenkins:
      is_vagrant => true,
}

include orcid_postgres
