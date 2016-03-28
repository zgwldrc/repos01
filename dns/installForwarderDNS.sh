#!/bin/bash

yum -y install bind bind-utils bind-chroot

sed -i '/DNS[0-9]*/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/DNS[0-9]*/d' /etc/sysconfig/network

service network restart
chkconfig --level 35 named on
service named start
