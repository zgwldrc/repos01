#!/bin/bash

wget ftp://zgwldrc.xy.cn/rpms/puppet-agent-1.4.0-1.el6.x86_64.rpm || sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm && yum install puppet-agent




rpm -ivh puppet-agent-1.4.0-1.el6.x86_64.rpm

export PATH=/opt/puppetlabs/bin:$PATH

echo export PATH=/opt/puppetlabs/bin:\$PATH >> ~/.bashrc


/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true


/opt/puppetlabs/bin/puppet agent --test



