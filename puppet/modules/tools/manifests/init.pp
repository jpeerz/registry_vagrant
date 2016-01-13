class tools {

  # package install list
  $packages = [
    "curl",
    "git",
    "git-core",
    "ntp",
    "htop",
    "vim"
  ]

  # install packages
  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}
