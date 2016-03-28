#!/bin/bash
# accurate rsync powerd by zgwldrc
usage="Usage : $0  src_dir  [destination=basename of src_dir] server1 server2 servern... "

if [ $# -eq 0 ]
then
    echo $usage
    exit 1
fi

#-----src dir to monitor and sync----#
src=$1
#-----src dir to monitor and sync----#

#-----get desination to des variable----#
if [ ! -z $2 ]
then
    des=$2
    shift
    shift
else
    des=$(basename $1)
    shift
fi

#-----check if there has servers arguments----#
if [ $# -eq 0 ]
then
    echo $usage
    exit 1
fi

#-----get server list to servers variable-------#
servers=$@
#-----get server list to servers variable-------#

#---user and password defined in remote rsyncd-----#
user=rsync
passwd=rsync
#rsync_passwd_file=/etc/rsyncd.passwd

#----export env variable use to auto auth----#
export RSYNC_PASSWORD=$passwd


#----Now Begin to Monitor And do Rsync------#

cd ${src}
/usr/local/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file
do
        INO_EVENT=$(echo $file | awk '{print $1}')
        INO_FILE=$(echo $file | awk '{print $2}')
        echo "-------------------------------$(date)------------------------------------"
        echo $file
        
        #---event of create ,modify ,close_write ,moved_to---#

        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]
        then
                echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'

                for server in $servers
                do
                    #rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${server}::${des}
                    rsync -avzcR $(dirname ${INO_FILE}) ${user}@${server}::${des}
                done

        fi

        #---event of delete and moved---#

        if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
        then
                echo 'DELETE or MOVED_FROM'

                for server in $servers
                do
                    #rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${server}::${des}
                    rsync -avzR --delete $(dirname ${INO_FILE}) ${user}@${server}::${des}
                done
                
        fi

        if [[ $INO_EVENT =~ 'ATTRIB' ]]
        then
                echo 'ATTRIB'

                if [ ! -d "$INO_FILE" ]
                then
	            for server in $servers
		    do
			#rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${server}::${des}
			rsync -avzcR $(dirname ${INO_FILE}) ${user}@${server}::${des}
	            done
                fi
        fi
done
