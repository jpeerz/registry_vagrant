class shibboleth_nginx (
    $env,
    $host_name,
    $sb_entity_id,
    $ssl_dhparam,
    $ssl_certificate,
    $ssl_certificate_key,
    $about_ip_port,
    $api_ip_port,
    $members_ip_port,
    $communities_ip_port,
    $pub_ip_port,
    $registry_ip_port,
    $include_test_idps = false,) {

  include shibboleth_nginx::build_tools
  
    $packages = [ "liblog4cpp5-dev", 
        "libxerces-c-dev", "libxml-security-c-dev", "libgd3", "liblua5.1-0", 
        "libperl5.18", "libxslt1.1", "libpcre3-dev", "autotools-dev", "debhelper", 
        "dh-systemd", "libexpat1-dev", "libgd-dev", "libgeoip-dev", "liblua5.1-0-dev", 
        "libmhash-dev", "libpam0g-dev", "libperl-dev", "libxslt1-dev", "po-debconf", 
        "libboost1.55-all-dev", "libxmltooling-dev", "liblog4shib-dev", "libxerces-c2-dev",
        "xmltooling-schemas","libsaml2-dev","opensaml2-schemas","opensaml2-tools",
        "libboost1.55-dev","libfcgi-dev","supervisor"]

    package { $packages :
        ensure  => installed,
        require => [Exec["apt-get update"],Class["shibboleth_nginx::build_tools"], Package['ntp'] ]
    }

    file { "/src":
        ensure  => directory,
        owner   => root,
        group   => root,
    }	

    class {
        shibboleth_nginx::shibboleth:
            host_name => $host_name,
            sb_entity_id => $sb_entity_id,
            include_test_idps => $include_test_idps,
            require   => [Class["shibboleth_nginx::build_tools"], Class["shibboleth_nginx::nginx"], Package[$packages], Package["libcurl4-openssl-dev"]]         
    }
  
    class {
        shibboleth_nginx::nginx:
            host_name => $host_name,
            ssl_dhparam => $ssl_dhparam,
            ssl_certificate => $ssl_certificate,
            ssl_certificate_key => $ssl_certificate_key,
            about_ip_port => $about_ip_port,
            api_ip_port => $api_ip_port,
            communities_ip_port => $communities_ip_port,
            members_ip_port => $members_ip_port, 
            pub_ip_port => $pub_ip_port,
            registry_ip_port => $registry_ip_port,
            require    => [Class["shibboleth_nginx::build_tools"], Package[$packages]]
    }
}
