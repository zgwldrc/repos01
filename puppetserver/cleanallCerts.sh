#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin

 puppet resource service puppet ensure=stopped

 puppet resource service puppetserver ensure=stopped

 rm -rf /etc/puppetlabs/puppet/ssl

 puppet cert list -a

 puppet master --no-daemonize --verbose

 puppet resource service puppetserver ensure=running

 puppet resource service puppet ensure=running
