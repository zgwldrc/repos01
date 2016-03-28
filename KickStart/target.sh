#!/bin/bash
#
# Need to Mannualy Prepare a ISO image at /Data/iso/CentOS-6.5-x86_64-bin-DVD1.iso
#
##################################################################################
# Install NFS and Make Share
#############################
# Setup NFS share path
share_ro=/Data/nfs_share 
share_rw=/Data/download

# iso file location
iso_path=/Data/iso/CentOS-6.5-x86_64-bin-DVD1.iso

# iso mount point
mount_point=/Data/nfs_share/centos6.5

############################
# write mount info to fstab
############################
mkdir -p $mount_point
grep -q $mount_point /etc/fstab
if [ $? -eq 1 ];then
cat << eof >> /etc/fstab
$iso_path $mount_point iso9660 defaults,loop 0 0
eof
mount -a
fi

# Install NFS
yum -y install rpcbind nfs-utils
chkconfig --level 35 nfs on
chkconfig --level 35 rpcbind on
########################################
# Write Nfs share path to /etc/exports
########################################

cat << EOF > /etc/exports 
$share_rw *(rw,no_root_squash)
$share_ro *(ro,async,nohide,crossmnt)
EOF
###############
# Start Service
###############
service rpcbind restart
service nfs restart
#!/bin/bash
###########################################
# Install DHCP Server
##########################################
#import getipinfo.func
#it provide follows variables depends on eth0's ipinfo 
#ipaddr_and_prefix  eg. 192.168.1.1/24
#ipaddr             eg. 192.168.1.1
#prefix             eg. 24
#netaddr            eg. 192.168.1.0
#netmask            eg. 255.255.255.0
. ../functions/getipinfo.func


# ip ranges allowed for clients to get
range_start=100
range_end=200

#let myself become the dns of clients
#
dns1="$ipaddr"
#dns2=""
router="192.168.2.254"


zone=xy.cn

#setup a output file containing config of dhcpd
#
of="/tmp/$(basename %0).tmp"
:> $of
eth0="/etc/sysconfig/network-scripts/ifcfg-eth0"



#Install dhcpd
yum install -y dhcp
chkconfig --level 35 dhcpd on

########################
# Write dhcpd.conf
########################
# check zone value
if [ ! "x$zone" == "x" ];then
	echo "option domain-name \"$zone\";" >> $of
fi
# check dns value
if [ ! "x$dns1" == "x" ];then
	dns="$dns1"
	if [ ! "x$dns2" == "x" ];then
		dns="$dns,$dns2"
	fi
	echo "option domain-name-servers $dns;" >> $of
fi
# check router value
if [ ! "x$router" == "x" ];then
	echo "option routers $router;" >> $of
fi

cat << EOF >> $of
default-lease-time 24000;
max-lease-time 48000;
log-facility local7;

subnet $netaddr netmask $netmask {
  range ${netaddr%.*}.$range_start ${netaddr%.*}.$range_end;
  next-server $ipaddr;
  filename "pxelinux.0";
}
EOF
cp -f $of /etc/dhcp/dhcpd.conf
service dhcpd restart



######################################
# Install TFTP Server
######################################
tftp_root=/Data/tftpboot
mkdir -p $tftp_root



yum install -y tftp-server xinetd
sed -i "s?/var/lib/tftpboot?$tftp_root?" /etc/xinetd.d/tftp
chkconfig xinetd on
chkconfig tftp on
service xinetd restart
###########################
# Install syslinux package
###########################
yum install -y syslinux
cd /usr/share/syslinux
cp pxelinux.0 vesamenu.c32 $tftp_root
mkdir -p $tftp_root/pxelinux.cfg
#################################
# Copy File From ISO Image
#################################
mkdir -p $tftp_root/kernel/centos6.5
cd $mount_point/isolinux
cp -f splash.jpg $tftp_root
cp -f vmlinuz $tftp_root/kernel/centos6.5
cp -f initrd.img $tftp_root/kernel/centos6.5
cp -f isolinux.cfg $tftp_root/pxelinux.cfg/default
########################################
# Write KickStart Config File
########################################
#!/bin/bash

kickstart_file=/Data/nfs_share/kickstart/centos6.5.ks
mkdir -p ${kickstart_file%/*}

rootpw=xiayu123
pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvMl8ZfdiT7z5PDNpNV8cghr/y+HcY3ZSbhgTzZVZlpESUVqsEDA7L8gBHn845dZYpLUNNAmNFl7c61aR1EvEwEBlrkYDxaN6dsO5d9Smoc+odUtpFN5jzcI4NJ9pKVAscY1oEoMq7x/UiRVoeZMm1RhjXf3g5jFv8b8JGStnLqwGZRCPuFH5Haj7FzA5mj4wwn6UMM/Yhw1XnqP6QI6KJa8bVJb45kQgpPmziZ46TLGRUvTJgo7/DgLNK/F6kwzjvM3OYGa80YR0p8thWILeVMQ1bb+goz+H6k+6fGPhn5+pZyt3A9A7dCYNPOiX29y0UttWNV/BGEL6pYESFxTavw== root@zgwldrc.xy.cn"

##Begin Write KickStart config
#
#
cat << EOF > $kickstart_file

install
text
nfs --server=$ipaddr --dir=$mount_point
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto dhcp
rootpw $rootpw
authconfig  --enableshadow  --passalgo=sha512
firewall  --disabled
selinux  --disabled
timezone  Asia/Shanghai
bootloader --location=mbr --driveorder=vda,sda --append="crashkernel=auto rhgb quiet"
reboot
zerombr
clearpart --all
part  /      --fstype=ext4  --size=8196 
part  /boot  --fstype=ext4  --size=200
part  /Data  --fstype=ext4  --size=200 --grow
part  swap   --fstype=swap  --size=1024
services  --disabled  cups,kdump,acpid,portreserve

%packages
@additional-devel
@core
@development
@server-platform-devel
%end


%post
#!/bin/sh
# Import root admin's public key
#
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root.root /root/.ssh
echo "$pubkey" >> /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
chown root.root /root/.ssh/authorized_keys

# Change yum.repo to 163
cd /etc/yum.repos.d
mv CentOS-Base.repo CentOS-Base.repo.bak
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo CentOS-Base.repo
yum clean all
yum makecache


# Install ntpdate to sync time
yum install -y ntpdate
ntpdate s2m.time.edu.cn
ntpdate 202.112.7.13
hwclock -w


# optimize ssh link speed
#
sed -ri -e 's/#(UseDNS ).*/\1 no/' /etc/ssh/sshd_config
sed -i '/^GSSAPIAuthentication/s/yes/no/' /etc/ssh/sshd_config

# Mount NFS report itself's mac addr
mount -t nfs $ipaddr:$share_rw /mnt
# get macaddr
hwaddr="\$(ip link show eth0 | grep ether | awk '{print \$2}')"
echo \$hwaddr >> /mnt/maclist

umount /mnt

EOF
#-----Write KickStart file config Ending-----------#
###################################
# Edit pxelinux.cfg/default
###################################
cat << EOF > $tftp_root/pxelinux.cfg/default
default vesamenu.c32
timeout 60

menu background splash.jpg
menu title Welcome to CentOS 6.5!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color scrollbar 0 #ffffffff #00000000

label local
  menu label Boot from ^local drive
  menu default
  localboot 0xffff

label kickstart1
  menu label Boot from P^XE Server for KickStart Install CentOS6.5
  kernel ./kernel/centos6.5/vmlinuz
  append initrd=./kernel/centos6.5/initrd.img ks=nfs:$ipaddr:$kickstart_file
EOF
