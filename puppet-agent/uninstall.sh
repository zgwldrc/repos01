#!/bin/bash




/opt/puppetlabs/bin/puppet resource service puppet ensure=stopped enable=true


rpm -e --nodeps puppet-agent





