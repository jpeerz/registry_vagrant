# java -jar ~/bin/jenkins-cli.jar -s http://192.168.25.37:8090/ -i ~/.ssh/id_rsa install-plugin create-job NAME < xml
define orcid_jenkins::job(
  $jenkins_cli = "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/",
  $security = ""
) {
  # /var/lib/jenkins/jobs/ORCID-push_checker/
  $job_path = "/var/lib/jenkins/jobs"
  
  file { "/tmp/$title.xml":
    ensure => present
  }
  
  $create_job_command = "$jenkins_cli create-job $title < /tmp/$title.xml"
  
  notify { "Running: $create_job_command":}
  
  exec { "${title}_job":
    onlyif   => "test ! -d $job_path",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => $create_job_command,
    #require  => Service['jenkins']
  }
}