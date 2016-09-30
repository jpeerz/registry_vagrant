# Jenkins Upgrade from 1.x to 2.x

## Description

[ci-2.orcid.org](http://ci-2.orcid.org:8383/) is our current Jenkins server created and configured manually. Running version [1.639](http://pkg.jenkins-ci.org/debian/binary/jenkins_1.639_all.deb)

    jperez@ci-2:~$ apt-cache show jenkins
    Package: jenkins
    Status: install ok installed
    Installed-Size: 62198
    Version: 1.639
    Replaces: hudson


## Test and Simulation

In order to simulate the current state of ci-2, a vm was build with the exact jenkins version. and then puppet agent was executed via vagrant.

    SJO-WS2555:ci3 jperez$ vagrant reload --provision 
    ...
    ==> orcid_jenkins: Debug: /Stage[main]/Orcid_jenkins/Package[jenkins]/ensure: jenkins "1.639" is installed, latest is "2.23"
    ==> orcid_jenkins: Debug: Executing '/usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold install jenkins'
    ==> orcid_jenkins: Notice: /Stage[main]/Orcid_jenkins/Package[jenkins]/ensure: ensure changed '1.639' to '2.23'
    ==> orcid_jenkins: Debug: /Package[jenkins]: The container Class[Orcid_jenkins] will propagate my refresh event
    ...

We can confirm new version is installed with

    # apt-cache show jenkins
    Package: jenkins
    Version: 2.23
    Conffiles:
    /etc/logrotate.d/jenkins 9ccf66fc7b41f580d6c701e42d1bb794
    /etc/default/jenkins 7a7fd1d1e607ff49a0409780472c1ece
    /etc/init.d/jenkins e7d1b32adba36743f4655e2a2e1e19d8
    
## Step by Step

1. At ci-2 server
    * Backup installation folder /var/lib/jenkins
    
        ```
        root@ci-2:/var/lib# cp -Rfa jenkins/ jenkins_09302016/
        ```

    * Export existing configurations using jenkins-cli
    
        get-credentials-as-xml          Get a Credentials as XML (secrets redacted)
        get-credentials-domain-as-xml   Get a Credentials Domain as XML
        get-job                         Dumps the job definition XML to stdout.
        get-node                        Dumps the node definition XML to stdout.
        get-view                        Dumps the view definition XML to stdout.
        
    
        ```
        java -jar jenkins-cli.jar -i .ssh/id_rsa_jenkins -s http://ci-2.orcid.org:8383/ get-credentials-as-xml > credentials.xml
        java -jar jenkins-cli.jar -i .ssh/id_rsa_jenkins -s http://ci-2.orcid.org:8383/ get-credentials-domain-as-xml > credentials-domain.xml
        java -jar jenkins-cli.jar -i .ssh/id_rsa_jenkins -s http://ci-2.orcid.org:8383/ get-node > node.xml
        java -jar jenkins-cli.jar -i .ssh/id_rsa_jenkins -s http://ci-2.orcid.org:8383/ get-view > view.xml
        ```


TODO Migration

    
    
    
    
    
    
    
    
2. At ispuppet server
    * Update puppet _package_ definition to *latest* in file /root/git/registry_vagrant/puppet/modules/orcid_jenkins/manifests/init.pp
    ```
        package { "jenkins":
                ensure => latest,
                require => Exec["update_ubuntu_repos"]
        }
    ```
3. At ci-2 server
    * Run puppet agent command
4. Additional UI configuration steps are required
    * Follow instructions at [JENKINS/Upgrade+wizard](https://wiki.jenkins-ci.org/display/JENKINS/Upgrade+wizard)

## Validation

Browse to [ci-2.orcid.org](http://ci-2.orcid.org:8383/) and confirm service is available.

## Rollback

1. At ispuppet server
    * Update puppet _package_ definition to *latest* in file /root/git/registry_vagrant/puppet/modules/orcid_jenkins/manifests/init.pp
    ```
        package { "jenkins":
                ensure => 1.639,
                require => Exec["update_ubuntu_repos"]
        }
    ```
2. At ci-2 server
    * Run puppet agent command

## Risks and Considerations

* Puppet agent not able to downgrade properly in case of rollback
* Existing configuration not restored correctly after upgrade
* Pluing not available on new version


