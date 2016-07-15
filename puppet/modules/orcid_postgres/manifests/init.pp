class orcid_postgres {

  exec { "install puppet module postgresql":
    command => "sudo puppet module install puppetlabs-postgresql",
    unless => "sudo puppet module list | grep puppetlabs-postgresql",
  }

  class { 'postgresql::server': }
  
  postgresql::server::db { 'orcid':
    user     => 'orcid',
    password => postgresql_password('orcid', 'orcid123'),
  }
  
}