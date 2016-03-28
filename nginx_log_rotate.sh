#!/bin/bash
# run at 00:00 everyday

YEAR=$(date -d "yesterday" +"%Y")
MONTH=$(date -d "yesterday" +"%m")
DAY=$(date -d "yesterday" +"%d")
pidfile="$NGINX/logs/nginx.pid"
s_logs_file="$NGINX/logs/access.log"
d_logs_dir="$NGINX/logs/$YEAR/$MONTH"

mkdir -p ${d_logs_dir}
mv ${s_logs_file} ${d_logs_dir}/access_${DAY}.log
kill -USR1 `cat $pidfile`

