#!/bin/bash
# rsync 1.MyProjects to multi server
source functions/*
source regex/*
iplist=$(sed -e "$regex_fetchIpaddrFormat" /Data/download/serverip.list)

total=`echo $iplist | wc -w`
current=1

for ip in $iplist
do
	echo "Processing Server $ip ... [$current/$total]"

	rsync -av ~/1.MyProjects root@$ip:~ 	
	let "current++"
done
echo "ALL Complete! "
