#!/bin/bash

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true


/opt/puppetlabs/bin/puppet agent --test
