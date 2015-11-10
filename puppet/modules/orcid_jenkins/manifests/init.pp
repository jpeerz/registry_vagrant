class orcid_jenkins {
	
	include jenkins
	
	jenkins::plugin { 'git': }
	jenkins::plugin { 'git-client': }
	jenkins::plugin { 'github-api': }  

  file { "/var/cache/jenkins":
        ensure  => directory,
        owner => orcid_tomcat,
        group => orcid_tomcat,
  }

  file { "/var/log/jenkins":
        ensure  => directory,
        owner => orcid_tomcat,
        group => orcid_tomcat,
  }  

  $jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'

  $jenkins_port = '8383'
  $jenkins_user = 'orcid_tomcat'
  $jenkins_group = 'orcid_tomcat'
  $jenkins_email_list = 'angel.montenegro@avantica.net r.peters@orcid.org f.ramirez@ost.orcid.org w.simpson@orcid.org s.tyagi@ost.orcid.org'
  
  file { "/etc/default/jenkins":
        ensure        => file,
        path          => '/etc/default/jenkins',
        content       => template('orcid_jenkins/etc/default/jenkins.erb'),
  }          
}



