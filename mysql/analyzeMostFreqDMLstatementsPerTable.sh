#!/bin/bash
if [ $# -eq 0 ];then
  echo "Usage:%0 binlogfile"
  exit 1
fi

mysqlbinlog $1 | \
grep -i -e "^update" -e "^insert" -e "^delete" -e "^replace" -e "^alter" | \
cut -c1-100 | tr '[A-Z]' '[a-z]' | \
sed -e "s/\t/ /g;s/\`//g;s/(.*$//;s/ set .*$//;s/ as .*$//" | sed -e "s/ where .*$//" | \
sort | uniq -c | sort -nr

