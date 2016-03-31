
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

##Create the txgh.yml configuration file

**NOTE: Puppet will not run correctly without this file configured**

1. Copy puppet/modules/orcid_txgh/example-txgh.yml in the same directory and name it txgh.yml
        
        cp puppet/modules/orcid_txgh/example-txgh.yml puppet/modules/orcid_txgh/txgh.yml

2. Edit txgh.yml to add the credential information for your Github repo and Transifex project

        vim puppet/modules/orcid_txgh/txgh.yml

        txgh:
            github:
                repos:
                   #full github repo name including username
                   githubuser/repo-name:
                        #your github username
                        api_username: githubuser
                        #github personal api token - see https://github.com/blog/1509-personal-api-tokens
                        api_token: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                        #get this from the project URL when logged into transifex web UI (project URL like: https://www.transifex.com/account-name/transifex-project-id)
                        push_source_to: transifex-project-id
            transifex:
                projects:
                   #transifex project id - same as push_source_to value above
                   transifex-project-id:
                        #tx.config file location 
                        tx_config: "/home/orcid_txgh/txgh-master/config/tx.config"
                        #transifex username
                        api_username: transifexuser
                        #transifex password - same as web UI password
                        api_password: XXXXXXXXXXXXXXX
                        #full github repo name including username - same as repo name in repos section above
                        push_translations_to: githubuser/repo-name 

##Configure the TXGH server

1. Run vagrant txgh

        vagrant up txgh

2. SSH to txgh machine

        vagrant ssh txgh

3. Edit the tx.config file to include the information about your Transifex project resources

        vim txgh-master/config/tx.config

        [main]
        host = https://www.transifex.com

        #Create one such section per resource
        [txgh-test-2.api]
        file_filter = api_<lang>.properties
        source_file = api_en.properties
        source_lang = en
        type = PROPERTIES

tx.config file can also be generated automatically using the Transifex command line client. For more on formatting a tx.config file, see: http://docs.transifex.com/client/config/#txconfig                                                    

5. Start ngrok to expose localhost webhook port publicly (for local dev only)

        ./ngrok http 9292
This will generate an ngrok URL, which will be used to configure Github and Transifex webhooks

        Forwarding      https://ebefeec3.ngrok.io -> localhost:9292

6. Start the txgh server

        cd txgh-master
        rackup -o 0.0.0.0

##Configure Github webhook

1. Navigate to ```https://github.com/ORCID/[repository]/settings/hooks```
2. Click Add Webhook
3. Configure the webhook settings:

        * Payload URL: https://ebefeec3.ngrok.io/hooks/github
        * Content type: application/x-www-form-urlencoded
        * Secret: Leave blank
        * Which events: Just the push event
        
4. Click the Active checkbox, then click Add Webhook
5. Github will send a test to your webhook endpoint - this should return a ```200``` response 

##Configure Transifex webhook

1. Navigate to ```https://www.transifex.com/orcid-inc-1/[projectslug]/settings```
2. In the Webhook URL field, enter
        
        http://ebefeec3.ngrok.io/hooks/transifex

3. Click Save Project

##Test Github/Transifex sync

1. Ensure that both ngrok and txgh are running 
2. Make a change to your local git repo
2. Commit and push your changes to the Github remote
3. Verify webhook received and commit pushed to Transifex in TXGH console output
4. Log into [Transifex](https://www.transifex.com/signin) to verify that project resources were updated 




        


