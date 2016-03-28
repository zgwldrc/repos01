#!/bin/bash

#exec shell cmd on multi server with ssh

# ipmaclist generating from nmap scan
ipmaclist=/tmp/ipmaclist

total=`cat $ipmaclist | wc -l`
current=1

opt="-f -o StrictHostKeyChecking=no -o ConnectTimeout=5"



cmd='cd /tmp/repos01/puppet-agent && sh install.sh'

for ip in `cat $ipmaclist | cut -d" " -f1`
do
	echo "Processing Server $ip ... [$current/$total]"
    
	ssh $opt root@$ip $cmd &> /tmp/$0.$ip

    if [ $? -ne 0 ]
    then
    	echo "failed ,please look at /tmp/$0.$ip"
    else
    	echo "successed! "
    fi

	let "current++"
done
echo "ALL Complete! "
