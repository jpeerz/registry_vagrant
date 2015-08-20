class orcid_java  () {

   exec { "java install webupd8team":
      environment => [ "DEBIAN_FRONTEND=noninteractive" ], # same as export DEBIAN_FRONTEND=noninteractive
      command => "sudo add-apt-repository -y ppa:webupd8team/java",
      returns => [0, 1],
      creates => "/etc/apt/sources.list.d/webupd8team-java-trusty.list",
   }

   exec { "java install 0":
      command => "sudo /usr/bin/apt-get -q -y update",
      creates => "/usr/bin/java",
      require => Exec["java install webupd8team"],
   }
   
   exec { "java install 1":
      command => "sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",      
      require => Exec["java install 0"],
   }
   
   exec { "java install 2":
      command => "sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections",      
      require => Exec["java install 1"],
   }
   
   package {['oracle-java8-installer',]:
		ensure  => installed,
		require => Exec["java install 2"],
	}



}

