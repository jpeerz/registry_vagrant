class orcid_java  () {

   exec { "java install":
      environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
      command => template("orcid_java/scripts/install_java.erb"),
      creates => "/usr/bin/java",
      returns => [0, 1],
      require => Exec["apt-get update"],
   }

}

