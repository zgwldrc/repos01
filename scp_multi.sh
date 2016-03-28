#!/bin/bash

#exec shell cmd on multi server with ssh
if [ $# -lt 2 ];then

  echo "Usgae $(basename $0) IPLISTFILE COMMAND"
	exit 1;
fi

source regex/*
iplist=$(sed -e "$regex_fetchIpaddrFormat" $1)
src="$2"
dst="$3"
opt="-o StrictHostKeyChecking=no -o ConnectTimeout=2 -r -p"

total=`echo $iplist | wc -w`
current=1

for ip in $iplist
do
	echo "Processing Server $ip ... [$current/$total]"

	scp $opt $src root@$ip:$dst 
	let "current++"
done
echo "ALL Complete! "
