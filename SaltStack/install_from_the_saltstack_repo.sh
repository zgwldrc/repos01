#!/bin/bash
if [ $# -eq 0 ];then
     echo "Usage $0 master|minion|ssh|syndic|cloud"
     exit 1
fi

rpm --import https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub

cat << EOF >> /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for RHEL/CentOS \$releasever
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/SALTSTACK-GPG-KEY.pub
EOF

yum clean expire-cache
#yum update

case $1 in
	master)
		    yum install -y salt-master
		    ;;
	minion)
		    yum install -y salt-minion
		    ;;
	ssh)
		    yum install -y salt-ssh
		    ;;
	syndic)
		    yum install -y salt-syndic
		    ;;
	cloud)
		    yum install -y salt-cloud
		    ;;
	*)
	    echo "Usage $0 master|minion|ssh|syndic|cloud"
	    exit 1
	    ;;
esac
