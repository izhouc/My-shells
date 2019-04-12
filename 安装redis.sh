#!/bin/bash
#注意目录
#by dr
yum -y install gcc gcc-c++
tar -xf /root/dadadadadada/redis/redis-4.0.8.tar.gz
cd /root/redis-4.0.8/
make
make install
./utils/install_server.sh
/etc/init.d/redis_6379 stop
read -p "请输入端口"  port
read -p "请输入ip"  local_ip
sed -i "s/^bind.*/bind $local_ip/" /etc/redis/6379.conf 
sed -i "s/^port.*/port $port/" /etc/redis/6379.conf
#sed "\$CLIEXEC/'$CLIEXEC -h 192.168.4.51 -p 6351 shutdown'// "  /etc/init.d/redis_6379
/etc/init.d/redis_6379 start 
ss -ntlup | grep $port
redis-cli -h $local_ip -p $port
