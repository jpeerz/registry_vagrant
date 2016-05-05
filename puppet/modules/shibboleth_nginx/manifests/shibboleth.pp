class shibboleth_nginx::shibboleth($host_name, $sb_entity_id = sprintf("https://${host_name}/shibboleth/%s", fqdn_rand(10000000000)), $include_test_idps = false) {

    $sb_version = "shibboleth-sp-2.5.4"
    $sb_metadata_upload_file_name = sprintf("%s_Shibboleth_Metadata.xml", regsubst($sb_entity_id, '[:/.]+', '_', 'G'))
    
    notify{ "sb_entity_id is: ${sb_entity_id}": }
    
    # download the tgz file
    file { "/src/${sb_version}.tar.gz":
        path    => "/src/${sb_version}.tar.gz",
        source  => "puppet:///modules/shibboleth_nginx/src/${sb_version}.tar.gz",
        require => File["/src"],
    }
    
    $cmd = "/bin/tar xzvf /src/${sb_version}.tar.gz -C /src/. && chown -R root /src && chgrp -R root /src 
        cd /src/${sb_version} 
        sudo ./configure --with-fastcgi --prefix=/opt/shibboleth-sp 
        sudo make 
        sudo make install
        chown -R www-data /opt/shibboleth-sp && chgrp -R www-data /opt/shibboleth-sp
        sudo touch /opt/shibboleth-sp/puppet_built_${sb_version}"

    # untar the tarball at the desired location
    exec { "build shibboleth":
        command => $cmd,
        timeout     => 600,
        creates => "/opt/shibboleth-sp/puppet_built_${sb_version}",
        require => [File["/src/${sb_version}.tar.gz"]],
        notify  => [File["/opt/shibboleth-sp/etc/shibboleth/shibboleth2.xml"],File["/etc/supervisor/conf.d/shibboleth.conf"]]
    }
    
    file { "/etc/supervisor/conf.d/shibboleth.conf":
        path   => "/etc/supervisor/conf.d/shibboleth.conf",
        source => "puppet:///modules/shibboleth_nginx/etc/supervisor/conf.d/shibboleth.conf",
        notify => Service["supervisor"],
        require => Exec["build shibboleth"]
    }

    file { "/opt/shibboleth-sp/etc/shibboleth/shibboleth2.xml":
        path    => "/opt/shibboleth-sp/etc/shibboleth/shibboleth2.xml",
        content => template('shibboleth_nginx/opt/shibboleth-sp/etc/shibboleth/shibboleth2.xml'),
        notify  => [Service["shibd"], Service["supervisor"]],
        require => Exec["build shibboleth"]
    }

    file { "/opt/shibboleth-sp/etc/shibboleth/attribute-map.xml":
        path    => "/opt/shibboleth-sp/etc/shibboleth/attribute-map.xml",
        source => "puppet:///modules/shibboleth_nginx/opt/shibboleth-sp/etc/shibboleth/attribute-map.xml",
        owner   => www-data,
        group   => www-data,
        notify  => Service["shibd"],
        require => Exec["build shibboleth"]
    }

    if $include_test_idps {
        file { "/opt/shibboleth-sp/etc/shibboleth/mujina_metadata.xml":
			path    => "/opt/shibboleth-sp/etc/shibboleth/mujina_metadata.xml",
			source => "puppet:///modules/shibboleth_nginx/opt/shibboleth-sp/etc/shibboleth/mujina_metadata.xml",
			owner   => www-data,
			group   => www-data,
			notify  => Service["shibd"],
			require => Exec["build shibboleth"]
		}
    }

    file { "/opt/shibboleth-sp/share/published":
        source  => "puppet:///modules/shibboleth_nginx/opt/shibboleth-sp/share/published",
        recurse => true,
        require => Exec["build shibboleth"]
    }

    file { "/etc/init.d/shibd":
        path   => "/etc/init.d/shibd",
        mode   => '0755',
        source => "puppet:///modules/shibboleth_nginx/etc/init.d/shibd",
        notify => Service["shibd"],
        require => Exec["build shibboleth"]
    }


    service { "shibd":
        ensure    => running,
        enable    => true,
        notify  => Exec["upload shibboleth config"],
        require =>[File["/etc/init.d/shibd"]],
    }
  
    exec { "upload shibboleth config":
        command => "curl -k -H 'Host: ${host_name}' https://localhost/Shibboleth.sso/Metadata > /vagrant/${sb_metadata_upload_file_name}
        curl -i -F userfile=@//vagrant/${sb_metadata_upload_file_name} https://www.testshib.org/procupload.php",
        onlyif  => "test -e /vagrant",
        path    => ['/usr/bin','/usr/sbin','/bin','/sbin'],
        require =>[File["/etc/init.d/shibd"], Service["nginx"]],
    }
  
    service { "supervisor":
        ensure    => running,
        enable    => true,
        require =>[Package["supervisor"]],
    }

}
