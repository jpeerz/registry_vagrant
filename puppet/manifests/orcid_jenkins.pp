Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

# commented lines just as a guide line from /puppet/manifests/nodes.pp

include orcid_auto_upgrades

#include orcid::postgresql_9_3
#include orcid::postgresql_monitoring
#include orcid::postgresql_backups

include orcid_java

include orcid_maven

#include shibboleth_nginx

#include orcid_tomcat

#include orcid_deployment

#include orcid_private

#include standard

include orcid_jenkins

include orcid_jenkins::autoconfigure