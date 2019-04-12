#!/bin/bash
mysqldump -uroot -ptarena bbsdb user > /mybakdata/user-`date +%Y-%m-%d`.sql  &> /dev/null
echo "`date +%Y-%m-%d`的bbsdb库里的user表已备份.."
