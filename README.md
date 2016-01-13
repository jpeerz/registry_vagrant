
1.  Clone

    git clone git@github.com:ORCID/registry_vagrant.git

2. CD and install pluggin
    cd registry_vagrant
    vagrant plugin install vagrant-vbguest
    vagrant up tomcat

3.  set up tunnels (remember other servers on 8080 shouldn't be running)

    ./ssh_tomcat_tunnels

4. Open new command line cd to project 

    cd ~/git/registry_vagrant
    vagrant ssh tomcat
    sudo su - orcid_tomcat
    /home/orcid_tomcat/bin/scripts/deployment/deploy-app.py master




