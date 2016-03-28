#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin

 puppet resource service puppet ensure=stopped


 rm -r /etc/puppetlabs/puppet/ssl


 puppet resource service puppet ensure=running
