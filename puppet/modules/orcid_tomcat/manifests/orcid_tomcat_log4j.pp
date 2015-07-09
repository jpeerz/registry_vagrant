define orcid_tomcat::orcid_tomcat_log4j ($prefix=$title) {
  file { "orcid_tomcat_${prefix}.xml":
        ensure        => file,
        path          => "/home/orcid_tomcat/conf/${prefix}.xml",
        content       => template('orcid_tomcat/home/orcid_tomcat/conf/log4j.xml.erb'),
  }
}

