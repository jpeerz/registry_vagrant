# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include tools

user { "orcid_tomcat":
  ensure  => present,
  uid  => '7006',
  shell  => '/bin/bash',
  home  => '/home/orcid_tomcat',
  managehome => true,
  password => '$6$ZHUQRrIW.9iTAJ0Z$9vyWYor7k6SwxWvra5osKjZyuqHN30tQQJJFsrbDQkwfN1z1eRG7LUJUK6krOIWlCLCR9G05tA5pXfS4CPsyO/',
}

class { 'orcid_java': }

class {
  orcid_tomcat:
  tomcat_catalina_opts => '-Xmx2000m -XX:MaxPermSize=512m
-Dfile.encoding=utf-8 
-Dorg.orcid.config.file=file:///home/orcid_tomcat/git/ORCID-Source/orcid-persistence/src/main/resources/staging-persistence.properties 
-Dsolr.solr.home=/home/orcid_tomcat/bin/tomcat/webapps/orcid-solr-web/solr 
-Dsolr.data.dir=/home/orcid_tomcat/data/orcid-solr 
-Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true
',
  require => [Class["orcid_java"],User["orcid_tomcat"]]
}

