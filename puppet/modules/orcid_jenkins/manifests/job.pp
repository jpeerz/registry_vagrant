# java -jar ~/bin/jenkins-cli.jar -s http://192.168.25.37:8090/ -i ~/.ssh/id_rsa install-plugin create-job NAME < xml
define orcid_jenkins::job(
  $security    = "-i /var/lib/jenkins/.ssh/id_rsa_jenkins",
  $jenkins_cli = "java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8383/",
  $jenkins_home= "/var/lib/jenkins"
) {

  file { "/tmp/${title}.xml":
    ensure  => file,
    owner   => jenkins,
    group   => jenkins,    
    source  => "puppet:///modules/orcid_jenkins/jobs/${title}.xml"
  }
  
  $create_job_command = "$jenkins_cli $security create-job $title < /tmp/${title}.xml"
  
  #notify { "Running: $create_job_command":}
  
  exec { "${title}_job":
    require  => [
      File["/tmp/${title}.xml"]
    ],
    onlyif   => "test ! -d $jenkins_home/jobs/$title && test -f $jenkins_home/jenkins-cli.jar && test -f $jenkins_home/.ssh/id_rsa_jenkins",
    provider => 'shell',
    path     => ["/bin","/usr/bin"],
    cwd      => "$jenkins_home",
    command  => $create_job_command
  }
}
