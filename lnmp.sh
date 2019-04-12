#!/bin/bash
yum -y install gcc pcre-devel openssl-devel
tar -xf /root/lnmp_soft.tar.gz -C /opt/
cd /opt/lnmp_soft/
yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm  mariadb mariadb-server mariadb-devel php  php-mysql
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
useradd -s /sbin/nologin nginx
./configure --with-http_ssl_module --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module --with-stream
make && make install
systemctl restart mariadb php-fpm
systemctl enable mariadb php-fpm

