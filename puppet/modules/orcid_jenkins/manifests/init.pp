class orcid_jenkins {	
	
	class {'jenkins':
		user => 'orcid_tomcat',
		group => 'orcid_tomcat',
		manage_user  => false,
		manage_group => false,	
		install_java => false,
		service_enable	=> true,
		service_ensure	=> 'stopped',
		config_hash	=> {
			'HTTP_PORT' => {value => '8383'},
			'JENKINS_USER' => {value => 'orcid_tomcat'},
			'JENKINS_GROUP' => {value => 'orcid_tomcat'},
			'JAVA_HOME' => {value => '/usr/lib/jvm/java-8-oracle/'}
		},
		require => User['orcid_tomcat'],
	}
	
	jenkins::plugin { 'git': }
	jenkins::plugin { 'git-client': }
	jenkins::plugin { 'github-api': }  

	file { '/usr/share/jenkins/':		
		owner => orcid_tomcat,
		group => orcid_tomcat,    
		recurse => true,
	}
	
	file { '/var/cache/jenkins/':
		owner => orcid_tomcat,
		group => orcid_tomcat,    
		recurse => true,
	}
	
	file { '/var/run/jenkins/':
		owner => orcid_tomcat,
		group => orcid_tomcat,    
		recurse => true,
	}	
}



