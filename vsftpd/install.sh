#!/bin/bash

yum install -y vsftpd
chkconfig --level 35 vsftpd on
mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

cat << eof > /etc/vsftpd/vsftpd.conf
#################
#---ANONYMOUS---#
#################
anonymous_enable=YES
anon_world_readable_only=YES
#anon_other_write_enable=YES
#anon_mkdir_write_enable=YES
#anon_upload_enable=YES
anon_max_rate=0   # (byte per sec )
anon_umask=022
#anon_root=

################
##VIRTUAL-USER##
################
#guest_enable=YES
#guest_username=ftp
#virtual_use_local_privs=YES

########################
##LOCAL-USER-SETTING####
########################
local_enable=YES
#chroot_local_user=YES
#chroot_list_enable=YES
#chroot_list_file=/etc/vsftpd/chroot_list
#userlist_enable=YES
#userlist_deny=NO
#userlist_file=/etc/vsftpd/user_list
#allow_writeable_chroot=YES
local_umask=022
local_max_rate=0

###################
#--GLOBAL-SETING--#
###################
listen=YES
listen_port=21
write_enable=YES
use_localtime=YES
#user_config_dir=/etc/vsftpd/user.conf.d

####LOG-SETING####
xferlog_enable=YES
xferlog_file=/var/log/xferlog
xferlog_std_format=YES
dual_log_enable=NO
vsftpd_log_file=/var/log/vsftpd.log

####NETWORKING####
pasv_enable=YES
connect_from_port_20=NO
max_clients=2000
max_per_ip=50
max_login_fails=3
#pasv_min_port=0
#pasv_max_port=0
connect_timeout=60
accept_timeout=60
data_connection_timeout=300
idle_session_timeout=300

####SECURITY####
ascii_download_enable=NO
ascii_upload_enable=NO
one_process_model=NO
tcp_wrappers=NO
ls_recurse_enable=NO
nopriv_user=nobody
pam_service_name=vsftpd
eof
service vsftpd start
