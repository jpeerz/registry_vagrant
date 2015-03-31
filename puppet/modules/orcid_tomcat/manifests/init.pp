
class orcid_tomcat($local_password) {

   user { "orcid_tomcat":
      ensure  => present,
      uid  => '7006',
      shell  => '/bin/bash',
      home  => '/home/orcid_tomcat',
      managehome => true,
      password => $local_password,
   }

   file { "/home/orcid_tomcat/bin":
      ensure  => directory,
      owner => orcid_tomcat,
      group => orcid_tomcat,
      require => User["orcid_tomcat"],
   }
	
   $tomcat_bin = "apache-tomcat-8.0.21"
   $tomcat_tar = "${tomcat_bin}.tar.gz"

   # download the tgz file
    file { "$tomcat_tar":
        path    => "/tmp/$tomcat_tar",
        source  => "puppet:///modules/orcid_tomcat/$tomcat_tar",
        notify  => Exec["untar $tomcat_tar"],
    }

    # untar the tarball at the desired location
    exec { "untar $tomcat_tar":
        command => "/bin/tar xzvf /tmp/$tomcat_tar -C /home/orcid_tomcat/bin/. && chown -R orcid_tomcat /home/orcid_tomcat/bin/. && chgrp -R orcid_tomcat /home/orcid_tomcat/bin/. ",
        creates => "/home/orcid_tomcat/bin/$tomcat_bin",
        require => File["/tmp/$tomcat_tar", "/home/orcid_tomcat/bin"],
    }

  file { ["/usr/local/orcid", "/usr/local/orcid/webapps", "/usr/local/orcid/webapps/conf"]:
      ensure => directory,
  }



}
