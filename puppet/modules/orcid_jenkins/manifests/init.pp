class orcid_jenkins {	
	
	class {'jenkins':
		install_java => false,
		config_hash	=> {
			'HTTP_PORT' => {value => '8383'},	
			'JAVA_HOME' => {value => '/usr/lib/jvm/java-8-oracle/'},			
		},
	}
	
	jenkins::plugin { 'credentials': 
		version => '1.22',
	}
	jenkins::plugin { 'ssh-credentials': 
		version => '1.11',
	}
	jenkins::plugin { 'scm-api': 
		version => '0.2',
	}
	jenkins::plugin { 'mailer': 
		version => '1.15',
	}
	jenkins::plugin { 'matrix-project': 
		version => '1.4',
	}
	jenkins::plugin { 'junit': 
		version => '1.2',
	}
	jenkins::plugin { 'script-security': 
		version => '1.13',
	}
	jenkins::plugin { 'git-client': 
		version => '1.18.0',
	}
	jenkins::plugin { 'git': 
		version => '2.4.0',
	}	
	jenkins::plugin { 'plain-credentials': 
		version => '1.1',
	}
	jenkins::plugin { 'github-api': 
		version => '1.69',
	} 
	jenkins::plugin { 'github': 
		version => '1.14.0',
	}	 
	
	$jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'
}



