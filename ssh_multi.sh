#!/bin/bash

#exec shell cmd on multi server with ssh
if [ $# -lt 2 ];then

  echo "Usgae $(basename $0) IPLISTFILE COMMAND"
	exit 1;
fi

iplist=/tmp/ipmaclist


cmd="$@"
opt="-o StrictHostKeyChecking=no -o ConnectTimeout=2"

total=`cat $iplist | wc -l`
current=1

for ip in `cat $iplist | cut -d" " -f1`
do
	echo "Processing Server $ip ... [$current/$total]"

	ssh $opt root@$ip "$cmd"
	let "current++"
done
echo "ALL Complete! "


