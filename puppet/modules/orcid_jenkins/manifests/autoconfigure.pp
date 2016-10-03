define orcid_jenkins::autoconfigure {
    $plugins = [
        "pam-auth",
        "translation",
        "windows-slaves",
        "matrix-project",
        "javadoc",
        "subversion",
        "ant",
        "external-monitor-job",
        "mailer",
        "ldap",
        "ssh-credentials",
        "script-security",
        "maven-plugin",
        "cvs",
        "matrix-auth",
        "credentials",
        "ssh-slaves",
        "junit",
        "antisamy-markup-formatter"
    ]
    
    $jobs = [
        "ORCID-push_checker"
    ]
    
    file { "/var/lib/jenkins/.ssh/id_rsa_script":
        ensure  => file,
        source => "puppet:///modules/orcid_jenkins/id_rsa_script",
        owner   => jenkins,
        group   => jenkins,
        mode    => 600,
    }
    
    define install_jenkins_plugin($plugins_dir) {
        $plugin = "$plugins_dir/$title"
        exec { $title:
            onlyif   => "test ! -d $plugin",
            provider => 'shell',
            path     => ["/bin","/usr/bin"],
            cwd      => "/var/lib/jenkins/",
            command  => "java -jar ~/jenkins-cli.jar -s http://localhost:8383/ -i /var/lib/jenkins/.ssh/id_rsa_script install-plugin $title -deploy"
        }    
    }

    install_jenkins_plugin { $plugins: 
        plugins_dir => "/var/lib/jenkins/plugins"
    }    
    
}