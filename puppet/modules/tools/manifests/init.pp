class tools {

  # package install list
  $packages = [
    "curl",
    "git-core",
    "htop",
    "vim",
    "git"
  ]

  # install packages
  package { $packages:
    ensure => present,
    require => Exec["apt-get update"]
  }
}
