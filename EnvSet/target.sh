#!/bin/bash
main () {
	#$1   app_root
	#$2   admin_mail


	local APP_DOWNLOAD=${1:-/Data}/download
	local APP_SRC=${1:-/Data}/src
	local APP_LIB=${1:-/Data}/lib
	local ADMIN_MAIL=${2:-zgwldrc@163.com}

	#***Create app dirs
	mkdir -p $APP_DOWNLOAD
	mkdir -p $APP_SRC
	mkdir -p $APP_LIB


	#Start------------------------Write Bashrc File
        #
	#first bak old file
	mv -f ~/.bashrc ~/bashrc.bak

	{
		echo "#---------------------BASIC------------------------#"
		echo ""
		echo "# Source global definitions"
		echo "if [ -f /etc/bashrc ]; then"
		echo "	. /etc/bashrc"
		echo "fi"
		echo "alias rm='rm -i'"
		echo "alias cp='cp -i'"
		echo "alias mv='mv -i'"
		echo "alias yi='yum install -y'"
		echo "alias ys='yum search'"
		echo "alias rg='rpm -qa | grep'"
		echo "alias lh='ll -h'"
		echo "export APP_DOWNLOAD=$APP_DOWNLOAD"
		echo "export APP_SRC=$APP_SRC"
		echo "export APP_LIB=$APP_LIB"
		echo "export ADMIN_MAIL=$ADMIN_MAIL"
		echo "export IP=\`ip a s eth0 | grep 'inet '|head -1 | awk '{print \$2}' | cut -d/ -f1\`"
	} > ~/.bashrc

	#End---------------Write Bashrc File
        

        #Start--------------------Get report about bashrc---------------------------

	echo ""
	echo -e "\033[32m----------------bashrc-------------------------\033[0m"
	echo -e "\033[32mYour bashrc is like this...--------------------\033[0m"
	cat ~/.bashrc
	echo -e "\033[32m----------------bashrc-------------------------\033[0m"

        #End--------------------Get report about bashrc---------------------------


	#Start-------------------------Disabel SELINUX iptables

	setenforce 0 &> /dev/null
	sed -i '/SELINUX/s/enforcing/disabled/' /etc/sysconfig/selinux
	sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
	iptables -F
	chkconfig --level 35 iptables off

	#End-------------------------Disabel SELINUX iptables
}

main $@
