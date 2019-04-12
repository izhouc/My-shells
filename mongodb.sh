#!/bin/bash
make_mongodb(){
read -p "请输入你的mongodb数据库压缩包的绝对路径： "  path
cd $path
tar -xf mongodb-linux-x86_64-rhel70-3.6.3.tgz
mkdir /usr/local/mongodb
mkdir -p /usr/local/mongodb/etc  /usr/local/mongodb/log  /usr/local/mongodb/data/db
cp -r  mongodb-linux-x86_64-rhel70-3.6.3/bin  /usr/local/mongodb/

echo "logpath=/usr/local/mongodb/log/mongodb.log
logappend=true
dbpath=/usr/local/mongodb/data/db
fork=true" > /usr/local/mongodb/etc/mongodb.conf
}


echo "alias ms='/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf'
alias mt='/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf --shutdown'" >> /root/.bashrc



source /root/.bashrc

read -p "请输入需要更改的端口 " p
read -p "请输入需要更改的ip地址" ip

echo "port=$p
bind_ip=$ip" >>  /usr/local/mongodb/etc/mongodb.conf

ln -s  /usr/local/mongodb/bin/mongo  /sbin
ms
mongo --host $ip --port $p

