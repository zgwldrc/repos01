#!/bin/bash
#variables define

#import getipinfo.func
#it provide follows variables depends on eth0's ipinfo
#ipaddr_and_prefix  eg. 192.168.1.1/24
#ipaddr             eg. 192.168.1.1
#prefix             eg. 24
#netaddr            eg. 192.168.1.0
#netmask            eg. 255.255.255.0
. ../functions/getipinfo.func


# the $(hostname) has FQDN format
hostname=$(hostname)

# so cut it to hostname only
hostnameonly=${hostname%%.*}

# get the zone name
ZONE=${hostname#*.}

# localnet zone file
ZONEFILE=/var/named/${ZONE}.zone
ZONEFILE_RRT=/var/named/${ZONE}.zone.rrt

# external view zone file
ZONEFILE_EXT=/var/named/${ZONE}.zone.ext

# config file
CONF=/etc/named.conf
##############################
# Copy sample file to /etc
##############################
echo y|cp -f named.conf $CONF
##############################
# add zone block in ${CONF}
##############################
cat << EOF >> ${CONF}
view "local" {
    match-clients { $netaddr/$prefix;127/8; };

        zone "${ZONE}." IN {
            type master;
            file "${ZONEFILE}";
        };

	zone "`echo $ipaddr | awk -F. '{print $3"."$2"."$1}'`.in-addr.arpa." IN {
	    type master;
	    file "${ZONEFILE_RRT}";
	};

    include "/etc/named.rfc1912.zones";

};

view "external" {
    match-clients { any;};

        zone "${ZONE}." IN {
            type master;
            file "${ZONEFILE_EXT}";
        };
};

EOF
tail -25 ${CONF}
#################################
#create zone file in /var/named/
#################################
echo y|cp -a /var/named/named.localhost                       ${ZONEFILE}
sed -i "s/@ rname.invalid./$hostnameonly.${ZONE}. root.${ZONE}./" ${ZONEFILE}
sed -i "s/NS.*@/NS\t$hostnameonly.${ZONE}./"                      ${ZONEFILE}
sed -i '/[[:blank:]]A/d'                                      ${ZONEFILE}

#create rrt zone file
echo y|cp -a       ${ZONEFILE}              ${ZONEFILE_RRT}

#create external zone file
echo y|cp -a       ${ZONEFILE}              ${ZONEFILE_EXT}

# add essential info
# first import function to utilize
. ./func_addDnsARecords.func

func_addDnsARecords $hostnameonly $ipaddr

# show result
cat ${ZONEFILE}

# Create addDnsARecords Function

cat ./func_addDnsARecords.func >> ~/.bashrc

