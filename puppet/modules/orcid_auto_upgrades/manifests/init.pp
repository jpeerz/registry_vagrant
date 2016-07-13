class orcid_auto_upgrades {

  package { 'unattended-upgrades':
  	ensure => installed
  }
  
  file { '/etc/apt/apt.conf.d/20auto-upgrades':
    mode   => '0644',
    owner => root,
    group => root,
    source => 'puppet:///modules/orcid_auto_upgrades/etc/apt/apt.conf.d/20auto-upgrades',
    require => Package['unattended-upgrades'],
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    mode   => '0644',
    owner => root,
    group => root,
    source => 'puppet:///modules/orcid_auto_upgrades/etc/apt/apt.conf.d/50unattended-upgrades',
    require => Package['unattended-upgrades'],
  }

}