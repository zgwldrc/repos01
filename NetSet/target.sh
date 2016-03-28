#!/bin/bash
# Set My System networking Environment
# System CentOS6.5
# Author XiaYu 2016-02-27
#$1   FQDN
#$2   ipaddr/prefix
#$3   gateway
#$4   dns1
#$5   dns2
#$6   interface
func_SetStrValInFile() {
# $1:    string look for
# $2:    in which file
# ${!1}: value of the string,the string must uniq in file

if [ $# -eq 0 ];then
    echo "Usage :$(basename $0) ARG1(string look for) ARG2(in which file)"
    exit 1
fi

    grep -q ${1} ${2}

        if [ $? -eq 0 ];then
            sed -i "/${1}/s/.*/${1}=${!1}/" ${2}
        else
            echo "${1}=${!1}" >> ${2}
        fi
}
#!/bin/bash
# Example: func_SetIPADDR $ipaddr $gateway $dns1 $netmask $interface 

func_SetIPADDR() {
# $1:        value of IPADDR/PREFIX
# $2:        which interface to Set (default eth0)

local usage="$0 IPADDR/PREFIX [interface=eth0]"

	if [ $# -eq 0 ];then
		echo $usage
		exit 1
	fi

        ipcalc -4c $1 || exit 1
        	
        local LIST=(DEVICE BOOTPROTO HWADDR IPADDR ONBOOT PREFIX)

local	FILE=/etc/sysconfig/network-scripts/ifcfg-${2:-eth0}
local	DEVICE="${2:-eth0}"
local	BOOTPROTO="none"
local	HWADDR="$(ip link show ${2:-eth0} | grep ether | awk '{print $2}')"
local	IPADDR=`echo $1 | cut -d/ -f1`
local	PREFIX=`ipcalc -p $1 | cut -d= -f2`
local	ONBOOT="yes"

local i
        for i in ${LIST[@]}
	do
	    func_SetStrValInFile $i $FILE
	done

	echo -e "\033[32m------------------------------------\033[0m"
	echo -e "\033[32mYour ip args is like this...--------\033[0m"
	cat $FILE
	echo -e "\033[32m------------------------------------\033[0m"
	
}
#!/bin/bash
# $1  GATEWAY
# $2  DNS1
# $3  DNS2
func_setnetworking() {
	local usage="$0 GATEWAY DNS1 [DNS2]"

	if [ $# -lt 2 ]
	then
	    echo $usage
	    exit 1
	fi

local	FILE=/etc/sysconfig/network-scripts/ifcfg-eth0
local	GATEWAY=$1
local	DNS1=$2
local	DNS2=${3:-nodef}

	if [[ "$DNS2" != "nodef" ]]
	then

	  local LIST=(GATEWAY DNS1 DNS2)

	else
	 
	  local LIST=(GATEWAY DNS1)

	fi
local i
	for i in ${LIST[@]}
	do
	func_SetStrValInFile $i $FILE
	done

        echo -e "\033[32m------------------------------------\033[0m"
        echo -e "\033[32mYour networking args is like this...--------\033[0m"
        cat $FILE
        echo -e "\033[32m------------------------------------\033[0m"
}




usage="$0 ipaddr gateway domain dns netmask interface hostname approot  admin_mail"

main () {

	#$1   FQDN
	#$2   ipaddr/prefix
	#$3   gateway
	#$4   dns1
	#$5   dns2
	#$6   interface

	usage="$0 FQDN ipaddr/prefix gateway dns1 [dns2 [interface=eth0 ]]"

	if [ $# -lt 4 ] 
	then
	  echo $usage
	  exit 1
	fi

	#check for ipaddr/prefix
	ipcalc -4c $2 || exit 1


	#***Set SYSTEM ENV
        #hostname
    local    HOSTNAME=$1
    local    DOMAIN=${1#*.}
    sysctl -w kernel.hostname=$1
    func_SetStrValInFile HOSTNAME /etc/sysconfig/network
    func_SetStrValInFile DOMAIN   /etc/sysconfig/network
    

	#ipaddr
	func_SetIPADDR $2 $6

	#network
	func_setnetworking $3 $4 $5

}

#--------------action-------------#

usage="$0 FQDN ipaddr/prefix gateway dns1 [dns2 [interface=eth0 ]]"

        if [ $# -lt 4 ]
        then
          echo $usage
          exit 1
        fi

main $@
