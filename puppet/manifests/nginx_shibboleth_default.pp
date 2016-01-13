# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include orcid_base::baseapps
include orcid_base::common_libs

class {
   shibboleth_nginx:
      env => 'dev',
      api_ip_port => "127.0.0.1:8080",
      about_ip_port => "127.0.0.1:8888",
      communities_ip_port => "127.0.0.1:7777",
      members_ip_port => "127.0.0.1:9999",
      pub_ip_port => "127.0.0.1:8080",
      registry_ip_port => "127.0.0.1:8080",
      host_name => $HOST_NAME,
      sb_entity_id => $SB_ENTITY_ID,
      ssl_dhparam => "puppet:///modules/shibboleth_nginx/etc/nginx/dhparam-snakeoil.pem",
      ssl_certificate => "puppet:///modules/shibboleth_nginx/etc/nginx/ssl-cert-snakeoil.pem",
      ssl_certificate_key => "puppet:///modules/shibboleth_nginx/etc/nginx/ssl-cert-snakeoil.key",
      include_test_idps => true,
}
