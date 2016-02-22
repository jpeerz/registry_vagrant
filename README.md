
# Setup

1.  Clone

        git clone git@github.com:ORCID/registry_vagrant.git

2. For TXGH, clone (transifex repo)[https://github.com/ORCID/transifex] inside registry_vagrant

        cd registry_vagrant
        git clone git@github.com:ORCID/transifex.git

3. Make sure you have Vagrant 1.7.2 or later.

        vagrant -v

3. CD and install pluggin

        cd registry_vagrant
        vagrant plugin install vagrant-vbguest


4. Make sure your hosts file has dns entries for subdomains in `/etc/hosts`

         127.0.0.1       localhost
         127.0.0.1       api.localhost
         127.0.0.1       communities.localhost
         127.0.0.1       members.localhost
         127.0.0.1       pub.localhost

# Running tomcat

1. Run vagrant tomcat

        vagrant up tomcat

2. Set up tunnels (remember other servers on 8080 shouldn't be running)

        ./ssh_tomcat_tunnels

3. Open new command line cd to project 

        cd ~/git/registry_vagrant
        vagrant ssh tomcat
        sudo su - orcid_tomcat
        /home/orcid_tomcat/bin/scripts/deployment/deploy-app.py master

# Running Nginx Shibboleth

1. Run vagrant nginx_shibboleth

         vagrant up nginx_shibboleth

2. Set host name(Linux and OSX):

         export HOST_NAME="localhost"

3. Throw in nifty ssh hack to get around protected ports. Add 80 and 443 port forwards and 8080, 7777, 8888, 9999 reverse forward. 

         ./ssh_nginx_shibboleth_tunnels

4. Fire up any other services, tomcat or drupal. You don't have to have all of them running, just the ones you want to access through nginx.

| domain                 | proxies to port/path               | description                |
|------------------------|------------------------------------|----------------------------|
| localhost              | 8080/orcid-web or 8888/ or shib    | about server and registry  |
| api.localhost          | 8080/orcid-api-web                 | Registery API              |
| communities.localhost  | 7777/                              | communities                |
| members.localhost      | 9999/                              | members                    |
| pub.localhost          | 8080/orcid-pub-web                 | Registry Pub API           |

Hint: For tomcat you need to modify your VM arguments to support https and new domain:

        -Dorg.orcid.core.baseUri=https://localhost
        -Dorg.orcid.core.pubBaseUri=https://pub.localhost
        -Dorg.orcid.core.apiBaseUri=https://api.localhost

# Running txgh

1. Pull the latest from the transifex repo

        cd transifex
        git pull

2. Run vagrant txgh

        vagrant up txgh

2. SSH to txgh machine

        vagrant ssh txgh

3. Start txgh server (for testing - webhooks not yet configured)

        cd transifex/txgh
        rackup -o 0.0.0.0


4. Access at http://localhost:9292 

Note: default rack port is 9292; to access at http://localhost:8080 run
        
        cd transifex/txgh
        sudo rackup -p 80 -o 0.0.0.0



        


