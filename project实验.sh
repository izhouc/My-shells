#!/bin/bash
#仅供参考，已自己情况为准
#by dr
panduan(){
	if [ $? -eq 0 ];then
		 echo -e "安装$i\033[32m success \033[0m"
	else
		 echo -e "安装$i\033[31m fail \033[0m"
	fi
}

make_lamp(){
echo "正在部署依赖环境，请稍后........"
tar -xf lnmp_soft.tar.gz 
cd lnmp_soft/
yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm > /dev/null
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
yum -y install gcc pcre-devel openssl-devel > /dev/null
useradd nginx
echo "将会开启nginx功能,请稍后........."
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-stream --with-http_stub_status_module > /dev/null
make > /dev/null
make install > /dev/null
ln -s /usr/local/nginx/sbin/nginx /sbin/
nginx 
}

php_conf_nginx(){
echo "将会开启php,请稍后........."
yum -y install php php-mysql > /dev/null
sed -i "/pass the PHP/a}" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a include        fastcgi.conf;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_index  index.php;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_pass   127.0.0.1:9000;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a root           html;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a location ~ \.php$ {" /usr/local/nginx/conf/nginx.conf
nginx -s reload
}

nginx_lvs(){
echo "
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
"  >> /etc/sysctl.conf
cd /etc/sysconfig/network-scripts/
echo "即将将vip：192.168.4.253写入"
#cp ifcfg-lo{,:0}
echo '
DEVICE=lo:0
IPADDR=192.168.4.253
NETMASK=255.255.255.255
NETWORK=192.168.4.253
BROADCAST=192.168.4.253
ONBOOT=yes
NAME=lo:0
' > ifcfg-lo:0
systemctl restart network
}

make_mysql(){
mkdir /dr
tar -xf mysql-5.7.17.tar -C /dr/
cd /dr
yum -y install mysql-community-* > /dev/null
echo ""
systemctl enable mysqld
systemctl start mysqld
}

master_log_bin(){
echo "仅支持配置文件修改，添加用户请另开终端"
log_bin=`hostname | awk '{print $1}'`
echo "日志名将设置为$log_bin"
server_id=`ifconfig |head -2 |  awk  -F. '/inet /{print $4}' | awk '{print $1}'`
echo "mysql的id号将为主机ip最后一位$server_id"
echo "
server_id=$server_id
log-bin=$log_bin
plugin-load=rpl_semi_sync_master=semisync_master.so
rpl_semi_sync_master_enabled=1
" > /etc/my.cnf
systemctl restart mysqld
}

slave_log_bin(){
echo "仅支持配置文件修改，添加用户请另开终端"
log_bin=`hostname | awk '{print $1}'`
echo "日志名将设置为$log_bin"
server_id=`ifconfig |head -2 |  awk  -F. '/inet /{print $4}' | awk '{print $1}'`
echo "mysql的id号将为主机ip最后一位$server_id"
echo "
server_id=$server_id
log-bin=$log_bin
plugin-load=rpl_semi_sync_slave=semisync_slave.so
rpl_semi_sync_slave_enabled=1
" > /etc/my.cnf
systemctl restart mysqld
}

mysql_maxscale(){
echo "仅支持配置文件修改，请根据配置文件在相应mysql上添加用户"
yum -y install maxscale-2.1.2-1.rhel.7.x86_64.rpm
mv ./maxscale.cnf.template /etc/maxscale.cnf.template
maxscale -f  /etc/maxscale.cnf 
}

project_lvs(){
yum install -y ipvsadm keepalived > /dev/null
systemctl enable keepalived
echo "即将将默认vip：192.168.4.253，rip:192.168.4.33/44的配置文件导入"
read -p "若为master请输入1，backup请输入2" master_backup	
	if [ $master_backup -eq 1 ];then
		 mv ./master.conf /etc/keepalived/keepalived.conf
	elif [ $master_backup -eq 2 ];then
		 mv ./backup.conf /etc/keepalived/keepalived.conf
	else
		 echo "输入错误请重新执行本条命令"
	fi
ipvsadm -C
ipvsadm -Ln
systemctl start keepalived
}

project_svn(){
yum -y install subversion
mkdir /var/svn
svnadmin create /var/svn/project
echo "创建工作目录/var/svn/project"
echo "创建读写用户harry，密码123456，请及时自行修改"
echo "连接nfs，上传代码，请自行搞定，祝好运"
sed -i '/# anon-access = none/anon-access = none/' /var/svn/project/conf/svnserve.conf
sed -i '/# auth-access = write/auth-access = write/' /var/svn/project/conf/svnserve.conf
sed -i '/# password-db = passwd/password-db = passwd/' /var/svn/project/conf/svnserve.conf
sed -i '/# authz-db = authz/authz-db = authz/' /var/svn/project/conf/svnserve.conf
echo '[users]' >> /var/svn/project/conf/passwd
echo 'harry = 123456'  >> /var/svn/project/conf/passwd
echo '[/]' >> /var/svn/project/conf/authz 
echo 'harry = rw ' >> /var/svn/project/conf/authz
svnserve -d  -r /var/svn/project
}

project_nfs(){
echo "只进行默认配置更改，如拓扑更换请按情况修改脚本"
echo "正在部署依赖环境，请稍后......."
systemctl enable rpcbind ;  systemctl enable nfs
echo '
/var/nfs           192.168.4.33/24(ro)
/var/nfs           192.168.4.44/24(ro)
/var/nfs           192.168.4.40/24(rw,no_root_squash)
' > /etc/exports
echo "请去web服务器和svn服务器挂载，注意写入/etc/fstab"
systemctl restart rpcbind ; systemctl restart nfs 
}

read -p "请按照提示一步一步进行安装,按任意键继续:" 
echo "本脚本为实现快速自动化，请确定本机已配好yum源"
echo "确保root下有lnmp_soft.tar.gz和mysql-5.7.17.tar"
echo "若要实现读写分离请在root下准备maxscale-2.1.2-1.rhel.7.x86_64.rpm"
echo "若无请先退出"
PS3="请选择配置的服务："
select i in "部署nginx服务" "部署nginx的php动静分离"  "部署keepalived+lvs" "部署mysql" "部署mysql主从的主库"  "部署mysql主从的从库"  "部署project_lvs"  "部署project_svn" "部署project_nfs"  "退出"  
do
	case $i in 
		 部署nginx服务)
			 make_lamp
			 panduan
		 ;;
		 部署nginx的php动静分离)
			 php_conf_nginx
			 panduan
		 ;;
		部署keepalived+lvs)
			 nginx_lvs
			 panduan
		;;
		 部署mysql)
			 make_mysql
			 panduan
		 ;;
		部署mysql主从的主库)
			 master_log_bin
			 panduan
		 ;;
		部署mysql主从的从库)
			 slave_log_bin
			 panduan
		 ;;
		部署project_lvs)
			 project_lvs 
			 panduan		
		;;
		部署project_svn)
			 project_svn
			 panduan		
		;;
		部署project_nfs)
			 project_nfs
			 panduan		
		;;
		退出)
			echo "byebye"
		 	exit	
		 ;;	
		*)
			echo "请输入正确选项"
	esac
done
