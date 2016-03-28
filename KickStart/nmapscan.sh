#!/bin/bash
. ../functions/SetStrValInFile.func
. ../functions/getipinfo.func

# Source list from client reports their macaddr
maclist=$(cat /Data/download/maclist)

target=${1:-$ipaddr_and_prefix}

# get ip mac mix info list from nmap
nmap -sP $target -oN /tmp/scanlist &> /dev/null

# flush a final ip mac list
:> /tmp/ipmaclist

for mac in $maclist
do
    ip=$(grep -i -B 2 $mac /tmp/scanlist | head -1 | awk '{print $5}')
    SetStrValInFile "$mac" "$ip $mac" /tmp/ipmaclist
done
echo "ip mac list in /tmp/ipmaclist :"
cat /tmp/ipmaclist
