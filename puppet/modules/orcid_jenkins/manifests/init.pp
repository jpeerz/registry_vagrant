class orcid_jenkins {	

	$jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'
	$jenkins_port = '8383'
	$jenkins_user = 'jenkins'
	$jenkins_group = 'jenkins'

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
		owner => jenkins,
		group => jenkins,
		require	=> Package["jenkins"]
	}

	file { "/var/cache/jenkins":
		ensure  => directory,
		owner => jenkins,
		group => jenkins,
		require   => File["/var/lib/jenkins"]
	}

	file { "/var/log/jenkins":
		ensure  => directory,
		owner => jenkins,
		group => jenkins,
		require   => File["/var/cache/jenkins"]
	}

	file { "/etc/apt/sources.list.d/jenkins.list":
		mode => 644,
		owner => jenkins,
		group => jenkins,
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
		subscribe   => File["/etc/default/jenkins"]
	}

	exec { "jenkins CLI jar":
		command => "curl http://localhost:8383/jnlpJars/jenkins-cli.jar > /var/lib/jenkins/jenkins-cli.jar",
		creates => "/var/lib/jenkins/jenkins-cli.jar",
		subscribe => Service["jenkins"]
	}

	install_plugin { "install maven-plugin":
		plugin_name => "maven-plugin",
		plugin_version => "2.12.1"
	}

	package { "libxml2-utils":
		ensure => installed,
	}

	define install_plugin($plugin_name, $plugin_version) {
		exec { "install jenkins plugin":
			command => "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383 install-plugin http://updates.jenkins-ci.org/download/plugins/$plugin_name/$plugin_version/$plugin_name.hpi -name $plugin_name",
			unless => "curl 'http://localhost:8383/pluginManager/api/xml?depth=1' | xmllint --xpath '//plugin[shortName=\"$plugin_name\"][version=\"$plugin_version\"]' -",
			require => Package["libxml2-utils"],
			notify => Service["jenkins"]
		}
	}

}



