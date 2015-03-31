
class orcid_tomcat($local_password) {

   user { "orcid_tomcat":
      ensure  => present,
      uid  => '7006',
      shell  => '/bin/bash',
      home  => '/home/orcid_tomcat',
      managehome => true,
      password => $local_password,
   }
   
}
