# java -jar ~/bin/jenkins-cli.jar -s http://192.168.25.37:8090/ -i ~/.ssh/id_rsa install-plugin create-job NAME < xml
define orcid_jenkins::job(
  $security    = "-i /var/lib/jenkins/.ssh/id_rsa_jenkins",
  $jenkins_cli = "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/",
  $job_path    = "/var/lib/jenkins/jobs"
) {

  file { "/tmp/${title}.xml":
    ensure  => file,
    owner   => jenkins,
    group   => jenkins,    
    source  => "puppet:///modules/orcid_jenkins/var/lib/jenkins/jobs/${title}.xml"
  }
  
  $create_job_command = "$jenkins_cli $security create-job $title < /tmp/${title}.xml"
  
  notify { "Running: $create_job_command":}
  
  exec { "${title}_job":
    require  => [
      File["/tmp/${title}.xml"]
    ],
    onlyif   => "test ! -d $job_path/$title && test -f /var/lib/jenkins/jenkins-cli.jar && test -f /var/lib/jenkins/.ssh/id_rsa_jenkins",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "/var/lib/jenkins/",
    command  => $create_job_command
  }
}