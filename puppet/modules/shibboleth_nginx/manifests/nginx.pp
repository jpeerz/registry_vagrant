class shibboleth_nginx::nginx (
    $host_name,
    $ssl_dhparam,
    $ssl_certificate,
    $ssl_certificate_key,
    $about_ip_port,
    $api_ip_port,
    $members_ip_port,
    $communities_ip_port,
    $pub_ip_port,
    $registry_ip_port,
    $txgh_ip_port, ) {

    /*

        # instructions for building nginx-common_1.4.6-1orcid1_all.deb
        # and nginx-extras_1.4.6-1orcid1_amd64.deb
    
        cd ~/src
        git clone https://github.com/nginx-shib/nginx-http-shibboleth.git
        bzr branch lp:ubuntu/trusty/nginx
        cd nginx
        vi debian/rules
        # in vi, add the following
        # --add-module=/home/vagrant/src/nginx-http-shibboleth \
        # to common_configure_flags
        dch -i
        # dch will prompt you to enter a comment describing the change
        # you should also change the version number on the first line to
        # 1.4.6-1orcid1
        bzr whoami '[your email]'
        debcommit
        bzr bd -- -b -us -uc
        sudo dpkg -i ../nginx-common_1.4.6-1orcid1_all.deb
        sudo dpkg -i ../nginx-extras_1.4.6-1orcid1_amd64.deb
        # Mark package as held, to stop apt replacing it with standard ubuntu one
        sudo apt-mark hold nginx-extras

    */

    file { "nginx-common_1.4.6-1orcid1_all.deb":
        path    => "/src/nginx-common_1.4.6-1orcid1_all.deb",
        source  => "puppet:///modules/shibboleth_nginx/src/nginx-common_1.4.6-1orcid1_all.deb",
        require => File["/src"],
    }

    file { "nginx-extras_1.4.6-1orcid1_amd64.deb":
        path    => "/src/nginx-extras_1.4.6-1orcid1_amd64.deb",
        ensure   => present,
        source  => "puppet:///modules/shibboleth_nginx/src/nginx-extras_1.4.6-1orcid1_amd64.deb",
        require => File["/src"],
    }

    exec { "install nginx_orcid1_amd64":
        command => template("shibboleth_nginx/scripts/nginx_orcid1_amd64.erb"),
        creates => "/var/lib/nginx/nginx-extras_1.4.6-1orcid1_amd64_puppet.touched",
        timeout     => 900,
        require => [File["nginx-common_1.4.6-1orcid1_all.deb"],File["nginx-extras_1.4.6-1orcid1_amd64.deb"]],
    }


    service { "nginx":
        ensure  => running,
        enable  => true,
        require => Exec["install nginx_orcid1_amd64"],
    }

    file { "/etc/nginx/sites-available/default":
        path    => "/etc/nginx/sites-available/default",
        content => template('shibboleth_nginx//etc/nginx/sites-available/default'),
        notify  => Service["nginx"],
        require => Exec["install nginx_orcid1_amd64"],
    }

    file { "/etc/nginx/ssl.key":
        path    => "/etc/nginx/ssl.key",
        source  => $ssl_certificate_key,
        notify  => Service["nginx"],
        require => Exec["install nginx_orcid1_amd64"],
    }

    # Generate cert by openssl dhparam -out dhparam.pem 4096 
    file { "/etc/nginx/dhparam.pem":
        path    => "/etc/nginx/dhparam.pem",
        source  => $ssl_dhparam,
        notify  => Service["nginx"],
        require => Exec["install nginx_orcid1_amd64"],
    }

    file { "/etc/nginx/ssl.crt":
        path    => "/etc/nginx/ssl.crt",
        source  => $ssl_certificate,
        notify  => Service["nginx"],
        require => Exec["install nginx_orcid1_amd64"],
    }

    cron { "nginx cache cleaner":
        command => "rm -rf /tmp/nginx/*",
        user => root,
        hour => 0,
        minute => 0
    }
 
    case $environment {

       sandbox: {
           file { "/usr/share/nginx/html/404.html":
               path    => "/usr/share/nginx/html/404.html",
               source  => "puppet:///modules/shibboleth_nginx/usr/share/nginx/html/404.html",
               notify  => Service["nginx"],
               require  => Exec["install nginx_orcid1_amd64"],
           }

           file { "/usr/share/nginx/html/maintenance.html":
               path    => "/usr/share/nginx/html/maintenance.html",
               source  => "puppet:///modules/shibboleth_nginx/usr/share/nginx/html/maintenance_sandbox.html",
               notify  => Service["nginx"],
               require  => Exec["install nginx_orcid1_amd64"],
           }

       }

       default: {
            file { "/usr/share/nginx/html/404.html":
               path    => "/usr/share/nginx/html/404.html",
               source  => "puppet:///modules/shibboleth_nginx/usr/share/nginx/html/404.html",
               notify  => Service["nginx"],
               require  => Exec["install nginx_orcid1_amd64"],
            }

           file { "/usr/share/nginx/html/maintenance.html":
               path    => "/usr/share/nginx/html/maintenance.html",
               source  => "puppet:///modules/shibboleth_nginx/usr/share/nginx/html/maintenance.html",
               notify  => Service["nginx"],
               require  => Exec["install nginx_orcid1_amd64"],
           }
       }


    }
 
    file { "/usr/share/nginx/html/50x.html":
        path    => "/usr/share/nginx/html/50x.html",
        source  => "puppet:///modules/shibboleth_nginx/usr/share/nginx/html/50x.html",
        notify  => Service["nginx"],
        require  => Exec["install nginx_orcid1_amd64"],
    }
 
}
