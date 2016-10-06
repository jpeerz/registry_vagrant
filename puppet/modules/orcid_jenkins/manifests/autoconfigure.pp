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
    "test"
  ]
  
  # "ORCID-push_checker",
        
  exec { "download_jenkins_cli":
    onlyif   => "test ! -f /var/lib/jenkins/jenkins-cli.jar",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => "wget -O /var/lib/jenkins/jenkins-cli.jar http://localhost:8383/jnlpJars/jenkins-cli.jar"
  }
  
  file { "/var/lib/jenkins/jenkins-cli.jar":
    ensure  => present,
    owner   => jenkins,
    group   => jenkins,
    require => Exec['download_jenkins_cli']
  }
      
  orcid_jenkins::job { $jobs:}

}