#!/bin/bash
yum makecache &> /dev/null
	yum clean all
num=`yum repolist | awk '/repolist/{print $2}' | sed 's/,//'`
if	[ $num -gt 0 ];then
	yum -y install httpd
	yum -y install mariadb mariadb-server mariadb-devel
	yum -y install php php-mysql
else
	echo "没有yum源.."
fi
