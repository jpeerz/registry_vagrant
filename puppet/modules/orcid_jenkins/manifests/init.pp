class orcid_jenkins {	
	
	exec { 'ensure_orcid_tomcat_is_ready':
		require => User["orcid_tomcat"],
	}

	class {'jenkins':
		lts => true,
		user => 'orcid_tomcat',
		group => 'orcid_tomcat',
		manage_user  => false,
		manage_group => false,
		install_java => false,		
	}
	
	jenkins::plugin { 'git': }
	jenkins::plugin { 'git-client': }
	jenkins::plugin { 'github-api': }    
}



