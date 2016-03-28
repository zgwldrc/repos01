#!/bin/bash
yum -y install ntp


sed -i '22i server s2m.time.edu.cn iburst' /etc/ntp.conf


