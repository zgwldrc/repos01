
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
