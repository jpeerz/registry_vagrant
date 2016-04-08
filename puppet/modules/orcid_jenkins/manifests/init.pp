class orcid_jenkins ($is_vagrant = false) {

	$jenkins_ext_fw = 'server custom tomcat tcp/8383 default accept'
	$jenkins_port = '8383'
	$jenkins_user = 'jenkins'
	$jenkins_group = 'jenkins'

	require orcid_tomcat

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
		ensure => latest,
		require => Exec["install jenkins 3"]
	}

	file { "/var/lib/jenkins":
		ensure  => directory,
		owner => jenkins,
		group => jenkins,
		require	=> Package["jenkins"]
	}

	file { "/var/lib/jenkins/hudson.tasks.Maven.xml":
		mode => 644,
		owner => jenkins,
		group => jenkins,
		source => "puppet:///modules/orcid_jenkins/var/lib/jenkins/hudson.tasks.Maven.xml",
		require   => File["/var/lib/jenkins"],
		notify => Service["jenkins"]
	}

	file { "/var/lib/jenkins/jobs/ORCID-push_checker":
		ensure  => directory,
		owner => jenkins,
		group => jenkins,
		source => "puppet:///modules/orcid_jenkins/var/lib/jenkins/jobs/ORCID-push_checker",
		recurse => true,
		require => Package["jenkins"]
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
		require => File["/var/log/jenkins"]
	}

	file { "/etc/default/jenkins":
		ensure => file,
		path => '/etc/default/jenkins',
		content => template('orcid_jenkins/etc/default/jenkins.erb'),
		require => File["/etc/apt/sources.list.d/jenkins.list"]
	} 

	# Vagrant puppet has issues starting a service vagrant
	if $is_vagrant == true {
		service { "jenkins":
			ensure	=> running,
			enable	=> true,
			subscribe   => File["/etc/default/jenkins"]
		}
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

	# GitHub plugin dependencies

	install_plugin { "install github-api":
		plugin_name => "github-api",
		plugin_version => "1.72.1"
	}

	install_plugin { "install icon-shim":
		plugin_name => "icon-shim",
		plugin_version => "2.0.3"
	}

	install_plugin { "install credentials":
		plugin_name => "credentials",
		plugin_version => "1.27"
	}

	install_plugin { "install ssh-credentials":
		plugin_name => "ssh-credentials",
		plugin_version => "1.11"
	}

	install_plugin { "install git-client":
		plugin_name => "git-client",
		plugin_version => "1.19.6"
	}

	install_plugin { "install scm-api":
		plugin_name => "scm-api",
		plugin_version => "1.1"
	}

	install_plugin { "install mailer":
		plugin_name => "mailer",
		plugin_version => "1.16"
	}

	install_plugin { "install matrix-project":
		plugin_name => "matrix-project",
		plugin_version => "1.6"
	}

	install_plugin { "install git":
		plugin_name => "git",
		plugin_version => "2.4.4"
	}

	install_plugin { "install token-macro":
		plugin_name => "token-macro",
		plugin_version => "1.12.1"
	}

	install_plugin { "install plain-credentials":
		plugin_name => "plain-credentials",
		plugin_version => "1.1"
	}

	# End GitHub plugin dependencies

	install_plugin { "install github":
		plugin_name => "github",
		plugin_version => "1.18.1"
	}

	package { "libxml2-utils":
		ensure => installed,
	}

	define install_plugin($plugin_name, $plugin_version) {
		exec { "install jenkins plugin $plugin_name":
			command => "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383 install-plugin http://updates.jenkins-ci.org/download/plugins/$plugin_name/$plugin_version/$plugin_name.hpi -name $plugin_name",
			unless => "curl 'http://localhost:8383/pluginManager/api/xml?depth=1' | xmllint --xpath '//plugin[shortName=\"$plugin_name\"][version=\"$plugin_version\"]' -",
			require => [Exec["jenkins CLI jar"], Package["libxml2-utils"]]
		}
	}

}



