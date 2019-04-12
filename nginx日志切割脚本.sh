#!/bin/bash
time=`date +%F`
logpath=/usr/local/nginx/logs

mv ${logpath}/access.log  ${logpath}/access-${time}.log
mv ${logpath}/error.log   ${logpath}/error-${time}.log
kill -USR1 $(cat ${logpath}/nginx.pid)
