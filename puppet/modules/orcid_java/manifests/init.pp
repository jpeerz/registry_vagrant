class orcid_java  () {

   exec { "java install webupd8team":
      environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
      command => "sudo add-apt-repository -y ppa:webupd8team/java",
      returns => [0, 1],
      creates => "/etc/apt/sources.list.d/webupd8team-java-trusty.list",
   }

   exec { "sudo apt-get update":
		command => "sudo /usr/bin/apt-get -q -y update",
		require => Exec["java install webupd8team"],
   }
   
   exec { "install java":	
    command => template("orcid_java/scripts/install_java.erb"),
    creates => "/usr/bin/java",
    require => Exec["sudo apt-get update"],	
   }      
       
}
