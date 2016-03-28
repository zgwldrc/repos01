#!/bin/bash
# check mysql service if is ok
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

mysql_port=${1:-3306}

ss -nlp | grep -q ":${mysql_port}\b"
rc=$?

if [ $rc -eq 0 ];then
  mysql --silent --connect_timeout=2 -e "show databases;" &> /dev/null
  rc=$?
  if [ $rc -eq 0 ];then
    status=0
  else
    status=1
  fi
else
  status=1
fi

exit $status
