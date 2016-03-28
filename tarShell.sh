#!/bin/bash

if [ $# -eq 0 ];then
  echo "Usage:$0 DIRNAME"
  exit
fi

rm -f $1-`date +%F`.tar.gz
tar zcvf `basename $1`-`date +%F`.tar.gz $1
