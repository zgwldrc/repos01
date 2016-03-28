#!/bin/bash

#exec shell cmd on multi server with ssh

# ipmaclist generating from nmap scan
ipmaclist=/tmp/ipmaclist


total=`cat $ipmaclist | wc -l`
current=1

opt="-o StrictHostKeyChecking=no -o ConnectTimeout=5"
cmd='rm -rf /tmp/repos01 && wget -rnH http://svn.xy.cn/repos01 -P /tmp &> /dev/null'

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
