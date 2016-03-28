#!/bin/bash

#exec shell cmd on multi server with ssh

# ipmaclist generating from nmap scan
ipmaclist=/tmp/ipmaclist


total=`cat $ipmaclist | wc -l`
current=1

opt="-o StrictHostKeyChecking=no -o ConnectTimeout=5"


#config clients new ip range
net=192.168.2.
startip=201
# config client hostname prefix
nprefix=app

#config client gateway
gw=192.168.2.254

# get zone name
zone=xy.cn
dns1=192.168.2.250
dns2=202.103.24.68


cmd='cd /tmp/repos01/EnvSet && sh target.sh && cd /tmp/repos01/NetSet && sh target.sh '

# target.sh FQDN ipaddr/prefix gateway dns1 [dns2 [interface=eth0 ]]
# varargs=""



for ip in `cat $ipmaclist | cut -d" " -f1`
do
	echo "Processing Server $ip ... [$current/$total]"
    
    varargs="$nprefix$startip.$zone $net$startip/24 $gw $dns1 $dns2"

	ssh $opt root@$ip $cmd$varargs &> /tmp/$0.$ip

    if [ $? -ne 0 ]
    then
    	echo "failed ,please look at /tmp/$0.$ip"
    else
    	echo "successed! Server $ip update to ip: $net.$startip hostname: $nprefix$startip.$zone"
    fi

	let "current++,startip++"
done
echo "ALL Complete! "
echo "Gate way is $gw"
echo "Dns1 is $dns1"
echo "Dns2 is $dns2"

