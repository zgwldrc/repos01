#!/bin/bash
# This function  make a file called "nsupdatefile" used by nsupdate
# You should use nsupdate like this:
# nsupdate -k pubkey -v nsupdatefile 

func_genNsUpdateFile() {
    
       echo -e "\033[32m"

    if [ $# -eq 0 ];then
       echo "Usage: $(basename $0) ddnsserverIP hostname hostip ttl"
       echo "No args detect,Use default args"
       echo ""
    fi
    local server=${1:-dns.$ZONE}
    local hostname=${2:-$(hostname)}
    local ipaddr=${3:-$IP}
    local ttl=${4:-600}

    {
      echo "server $server"
      echo "update delete $hostname"
      echo "update add $hostname $ttl A $ipaddr"
      echo "send"
    } > nsupdatefile

       echo "your invoke like this :"
       echo "$(basename $0) $server $(hostname) $ipaddr $ttl"
       echo "your nsupdateFile has been generated at ./nsupdatefile"
       echo "cat ./nsupdatefile"
       cat ./nsupdatefile
       echo -e "\033[0m"
}
func_genNsUpdateFile $1 $2 $3 $4
