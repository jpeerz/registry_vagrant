class orcid_java  () {

   exec { "java install webupd8team":
      environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
      command => "sudo add-apt-repository -y ppa:webupd8team/java",
      returns => [0, 1],
      creates => "/etc/apt/sources.list.d/webupd8team-java-trusty.list",
   }

   exec { "java install 1":
      command => template("orcid_java/scripts/install_java.erb"),
      creates => "/usr/lib/jvm/java-8-oracle/jre/lib/security/puppet_jce_installed",
      timeout     => 900,
      require => Exec["java install webupd8team"],
   }

}

