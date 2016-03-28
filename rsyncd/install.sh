#!/bin/bash
# install rsync as daemon as simple as possible
# if not exist $1 ,then get /Data/www as the path

syncpath=${1:-/Data/www}
syncname=`basename ${syncpath}`

authname=rsync
authpass=rsync

mkdir -p /etc/rsyncd

#----------write configure file-------------#
cat << EOF > /etc/rsyncd/rsyncd.conf
uid = root
gid = root
use chroot = no
max connections = 2
strict modes = yes
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[${syncname}]
path = $syncpath
ignore errors  = yes
read only = no
write only = no
list = false
auth users = $authname
secrets file = /etc/rsyncd/secrets.passwd

#hosts allow = 192.168.2.0/24
#hosts deny = *
EOF

#-------make secrets file-----------#
echo $authname:$authpass > /etc/rsyncd/secrets.passwd
chmod 600 /etc/rsyncd/secrets.passwd

#-------make restart script---------#
cat << EOF > /usr/local/sbin/rrsync
ps -C rsync && pkill rsync
sleep 2
rsync --daemon --config=/etc/rsyncd/rsyncd.conf -4
ps -C rsync
EOF

chmod +x /usr/local/sbin/rrsync


