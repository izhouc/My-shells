#!/bin/bash
yum clean all
yumlist=`yum repolist | awk -F: '/^repolist/{print $2}' | sed  's/,//'`
ngxdir=/usr/local/nginx/conf/nginx.conf
if [ $yumlist -ne 0 ];then
	yum -y install gcc pcre-devel openssl-devel
else
	echo "yum源没配置"
fi

nginx_install(){	
	read -p "请输入你nginx软件包的绝对路径：" ngx
cd $ngx
tar -xf nginx-1.12.tar.gz
./configure --with-http_module
make && make install
yum -y install php php-mysql mariadb mariadb-server mariadb-devel
	read -p "请输入你php-fpm软件包的绝对路径：" phpfpm
cd $phpfpm
yum -y install pfp-fpm-5.4.16-42.el7.x86_64.rpm
ln -s /usr/local/nginx/sbin/nginx /sbin
sed -i '/^http {/afastcgi_read_timeout 300;' $ngxdir
sed -i '/^http {/afastcgi_send_timeout 300;' $ngxdir
sed -i '/^http {/afastcgi_connect_timeout 300;' $ngxdir
sed -i '/^http {/afastcgi_buffer_size 32k;' $ngxdir
sed -i '/^http {/afastcgi_buffers 8 16k;' $ngxdir
sed -i '69,76s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '74d' /usr/local/nginx/conf/nginx.conf
sed -i "s/include        fastcgi_params;/include        fastcgi.conf;/" /usr/local/nginx/conf/nginx.conf

systemctl start mariadb php-fpm
systemctl enable mariadb php-fpm
nginx
}

ngxhtml=/usr/local/nginx/html
zabbix_install(){
	read -p "请输入你软件包的绝对路径：" zbx
cd $zbx
tar -xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4/
./configure --enable-server --enable-proxy --enable-agent --with-mysql=/usr/bin/mysql_config --with-net-snmp --with-libcurl
make && make install
cd frontends/php/
cp -a * $ngxhtml
chmod -R 777 $ngxhtml/*

}
e=`mysql -e`
mysql_show(){
$e "create database zabbix"
$e "grant all on zabbix.* to zabbix@localhost identified by 'zabbix'"
cd $zbx/zabbix-3.4.4/database/mysql/
mysql -uroot -pzabbix zabbix < schema.sql
mysql -uroot -pzabbix zabbix < images.sql
mysql -uroot -pzabbix zabbix < data.sql
}

