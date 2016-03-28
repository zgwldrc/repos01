#!/bin/bash

server=${1:-ntp}
yum install -y ntpdate
echo /usr/sbin/ntpdate  $server > /etc/cron.hourly/ntpdate


ntpdate $server
