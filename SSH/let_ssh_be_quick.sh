#!/bin/bash
sed -i '/^GSSAPIAuthentication/s/yes/no/' /etc/ssh/sshd_config
sed -ri -e 's/#(UseDNS ).*/\1 no/' /etc/ssh/sshd_config


