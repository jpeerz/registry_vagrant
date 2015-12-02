class orcid_jenkins {	

	$jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'
	$jenkins_port = '8383'
	$jenkins_user = 'orcid_tomcat'
	$jenkins_group = 'orcid_tomcat'	

	exec { "install jenkins 1":
		command => "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
	}
	
	exec { "install jenkins 2":	
		command => "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'",
		require => Exec["install jenkins 1"]
	}
	
	exec { "install jenkins 3":	
		command => "sudo apt-get update",
		require => Exec["install jenkins 2"]
	}
	
	package { "jenkins":
		ensure => installed,
		require => Exec["install jenkins 3"]
	}
	
	file { "/var/lib/jenkins":
		ensure  => directory,
		owner => orcid_tomcat,
		group => orcid_tomcat,
		require	=> Package["jenkins"]
	}

	file { "/var/cache/jenkins":
		ensure  => directory,
		owner => orcid_tomcat,
		group => orcid_tomcat,
		require   => File["/var/lib/jenkins"]
	}

	file { "/var/log/jenkins":
		ensure  => directory,
		owner => orcid_tomcat,
		group => orcid_tomcat,
		require   => File["/var/cache/jenkins"]
	}

	file { "/etc/apt/sources.list.d/jenkins.list":
		mode => 644,
		owner => orcid_tomcat,
		group => orcid_tomcat,
		source => "puppet:///modules/orcid_jenkins/etc/apt/sources.list.d/jenkins.list",
		require   => File["/var/log/jenkins"]
	}
	
	file { "/etc/default/jenkins":
		ensure        => file,
		path          => '/etc/default/jenkins',
		content       => template('orcid_jenkins/etc/default/jenkins.erb'),
		require   => File["/etc/apt/sources.list.d/jenkins.list"]
	} 

	service { "jenkins":
		ensure    => running,
		enable    => true,
		require   => File["/etc/default/jenkins"]
	}	
}



