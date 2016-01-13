class orcid_base::baseapps {

  # Every machine should have these packages and configuration files

  $packagelist = [
    "curl",
    "dnsutils",
    "emacs23-nox",
    "etckeeper",
    "git",
    "git-core",
    "haveged",
    "htop",
    "language-pack-en-base",
    "locate",
    "lsof",
    "mailutils",
    "mosh",
    "ntp",
    "openssh-server",
    "sudo",
    "tmux",
    "tcsh",
    "vim",
    "vim-common",
    "wget",
    "zip",
    "unzip",
  ]

  package { $packagelist:
    ensure => installed
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
    subscribe => File['sshd_config'],
    require => Package['openssh-server'],
  }

  file { 'sshd_config':
    path    => '/etc/ssh/sshd_config',
    ensure  => file,
    require => Package['openssh-server'],
    source  => 'puppet:///modules/orcid_base/etc/ssh/sshd_config',
  }

  file { '/etc/default/puppet':
    path   => '/etc/default/puppet',
    owner  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/orcid_base/etc/default/puppet',
  }

}

