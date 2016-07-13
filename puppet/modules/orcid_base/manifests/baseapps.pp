class orcid_base::baseapps ($enable_google_authenticator = false) {

  # Every machine should have these packages and configuration files

   exec { "install git-core ppa":
      environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
      command => "sudo add-apt-repository -y ppa:git-core/ppa",
      returns => [0, 1],
      creates => "/etc/apt/sources.list.d/git-core-ppa-trusty.list",
   }


  $packagelist = [
    "curl",
    "emacs23-nox",
    "etckeeper",
    "haveged",
    "htop",
    "language-pack-en-base",
    "libpam-google-authenticator",
    "locate",
    "lsof",
    "mailutils",
    "mosh",
    "tmux",
    "tcsh",
    "vim",
    "vim-common",
    "wget",
    "zip",
    "unzip",
  ]

  $packagelist_latest = [
    "dnsutils",
    "git",
    "git-core",
    "ntp",
    "openssh-server",
    "sudo",
  ]

  package { $packagelist:
    ensure => installed,
    require => [Exec['install git-core ppa']]
  }

  package { $packagelist_latest:
    ensure => latest,
    require => [Exec['install git-core ppa']]
  }

  ## Everyone deserves some good times.  Swap in a reasonable ntp.conf

  service { 'ntp':
    ensure    => running,
    enable    => true,
    subscribe => File['ntp.conf'],
  }

  file { 'ntp.conf':
    path    => '/etc/ntp.conf',
    ensure  => file,
    require => Package['ntp'],
    source  => 'puppet:///modules/orcid_base/etc/ntp.conf',
  }

  service { 'ssh':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ssh/sshd_config'],
    require => Package['openssh-server'],
  }

  if $enable_google_authenticator == true {
	  file { '/etc/pam.d/sshd':
		mode   => '0644',
		source => 'puppet:///modules/orcid_base/etc/pam.d/sshd',
		notify  => Service["ssh"],
		require => Package['libpam-google-authenticator'],
	  }
  }

  file { '/etc/security/access-local.conf':
    mode   => '0644',
    source => 'puppet:///modules/orcid_base/etc/security/access-local.conf',
    notify  => Service["ssh"],
    require => Package['libpam-google-authenticator'],
  }

  if $enable_google_authenticator == true { 
     file { '/etc/ssh/sshd_config':
        ensure  => file,
        require => Package['openssh-server','libpam-google-authenticator'],
        notify  => Service["ssh"],
        source  => 'puppet:///modules/orcid_base/etc/ssh/sshd_config_google_authenticator',
     }
  } else {
     file { '/etc/ssh/sshd_config':
        ensure  => file,
        require => Package['openssh-server'],
        notify  => Service["ssh"],
        source  => 'puppet:///modules/orcid_base/etc/ssh/sshd_config',
     }
  }

  file { '/etc/default/puppet':
    path   => '/etc/default/puppet',
    owner  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/orcid_base/etc/default/puppet',
  }

}

