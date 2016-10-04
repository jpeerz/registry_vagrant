Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
include orcid_auto_upgrades
include orcid_java
include orcid_maven
include orcid_deployment
class {orcid_jenkins: is_vagrant => true}