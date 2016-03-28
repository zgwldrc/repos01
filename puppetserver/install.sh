#!/bin/bash

#http://docs.puppetlabs.com/puppetserver/latest/install_from_packages.html



# Step1装puppetlab的repo
#http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html#yum-based-systems


#---action
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
yum install -y puppetserver
chkconfig puppetserver on
service puppetserver start

ln -s \
/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver \
/usr/local/sbin/puppetserver

ln -s \
/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf \
/etc/puppetserver.conf

echo "puppetserver    8140/tcp" >> /etc/services
