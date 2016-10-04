#!/bin/sh
if [ $(dpkg-query -s puppet | grep -c "3.8.1-1puppetlabs1") -eq 0 ];then
    sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
    sudo dpkg -i puppetlabs-release-trusty.deb
    sudo apt-get update
    sudo apt-get -q -y --force-yes install puppet=3.8.1-1puppetlabs1 puppet-common=3.8.1-1puppetlabs1
    sudo apt-mark -q hold puppet puppet-common
fi