class orcid_jenkins {	
	
	class {'jenkins':
		install_java => false,
		config_hash	=> {
			'HTTP_PORT' => {value => '8383'},			
		},
	}
	
	jenkins::plugin { 'git': }
	jenkins::plugin { 'git-client': }
	jenkins::plugin { 'github-api': }  	
}



