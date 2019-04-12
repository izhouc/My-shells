#!/bin/bash

#mysqldump -uroot -ptarena bbsdb > /mybakdata/bbsdb-allbak.sql  &> /dev/null
#oecho -e "\033[32m bbsdb 库已备份 \033[0m"

innobackupex --user root --password tarena --databases='bbsdb' /mybakdata/bbsdbbak-`date +%F`  --no-timestamp
