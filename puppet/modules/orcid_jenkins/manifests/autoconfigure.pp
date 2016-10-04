class orcid_jenkins::autoconfigure {
    $plugins = [
        "pam-auth",
        "plain-credentials",
        "workflow-step-api",
        "translation",
        "javadoc",
        "ssh-credentials",
        "ant",
        "external-monitor-job",
        "github-api",
        "credentials",
        "ldap",
        "ssh-slaves",
        "ghprb",
        "subversion",
        "rebuild",
        "script-security",
        "matrix-project",
        "matrix-auth",
        "maven-plugin",
        "ssh-agent",
        "antisamy-markup-formatter",
        "git",
        "cvs",
        "mailer",
        "git-client",
        "github",
        "slack",
        "scm-api",
        "junit",
        "windows-slaves"
    ]
    
    $jobs = [
        "ORCID-push_checker"
    ]
    # for new/fresh jenkins installation
    # rename mv /var/lib/jenkins/secrets/initialAdminPassword /var/lib/jenkins/secrets/initialAdminPasswordx
    # and use /modules/orcid_jenkins/files/var/lib/jenkins/bootstrap_config.xml <slaveAgentPort>49187</slaveAgentPort>
    # to accept CLI calls
    
    file { "/var/lib/jenkins/.ssh":
        ensure  => directory,
        owner   => jenkins,
        group   => jenkins
    }

    file { "/var/lib/jenkins/users/script":
        ensure  => directory,
        source => "puppet:///modules/orcid_jenkins/var/lib/jenkins/users/script/",
        owner   => jenkins,
        group   => jenkins
    }

    file { "/var/lib/jenkins/users/script/config.xml":
        ensure  => file,
        source => "puppet:///modules/orcid_jenkins/var/lib/jenkins/users/script/config.xml",
        owner   => jenkins,
        group   => jenkins
    }
    
    file { "/var/lib/jenkins/.ssh/id_rsa_script":
        ensure  => file,
        source => "puppet:///modules/orcid_jenkins/id_rsa_script",
        owner   => jenkins,
        group   => jenkins,
        mode    => 600
    }
    
    exec { "download_jenkins_cli":
        onlyif   => "test ! -f /var/lib/jenkins/jenkins-cli.jar",
        provider => 'shell',
        path     => ["/bin","/usr/bin"],
        cwd      => "/var/lib/jenkins/",
        command => "wget -O /var/lib/jenkins/jenkins-cli.jar http://localhost:8383/jnlpJars/jenkins-cli.jar"
    }
    
    file { "/var/lib/jenkins/jenkins-cli.jar":
        ensure  => file,
        owner   => jenkins,
        group   => jenkins
    }    
    
    define install_jenkins_plugin($plugins_dir) {
        $plugin = "$plugins_dir/$title"
        exec { $title:
            onlyif   => "test ! -d $plugin",
            provider => 'shell',
            path     => ["/bin","/usr/bin"],
            cwd      => "/var/lib/jenkins/",
            command  => "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/ -i /var/lib/jenkins/.ssh/id_rsa_script install-plugin $title -deploy >> /vagrant/plugins_installed.log"
        }    
    }
    # TODO reorder based on depency LIFO
    #install_jenkins_plugin { $plugins: 
    #    plugins_dir => "/var/lib/jenkins/plugins/"
    #}
    
    # /var/lib/jenkins/jobs/ORCID-push_checker/
    
}