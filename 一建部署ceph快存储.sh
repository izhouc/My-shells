#!/bin/bash

#搭建基本yum仓库
echo "[1]
name=1
baseurl=ftp://192.168.4.254/rhel7
enabled=1
gpgcheck=0" > /etc/yum.repos.d/rhel7.repo

#node1搭建yum仓库
echo "[mon]
name=mon
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/MON
enabled=1
gpgcheck=0
[osd]
name=osd
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/OSD
enabled=1
gpgcheck=0
[tools]
name=tools
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/Tools
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/ceph.repo

#创建解析
echo "192.168.4.10  client1
192.168.4.11     node1
192.168.4.12     node2
192.168.4.13     node3
192.168.4.14     node4
192.168.4.15     node5" >> /etc/hosts


#设置无密码远程连接
ssh-keygen -f  /root/.ssh/id_rsa  -N  ''
for i in 10 11 12 13 14 15
do
ssh-copy-id root@192.168.4.$i
done

#让每台node /etc/hosts统一
for i in 10 11 12 13 14 15
do
	scp  /etc/hosts  192.168.4.$i:/etc/
done

#scp传递yum仓库
for i in 10 11 12 13 14 15
do
	scp /etc/yum.repos.d/ceph.repo root@192.168.4.$i:/etc/yum.repos.d/
	scp /etc/yum.repos.d/rhel7.repo root@192.168.4.$i:/etc/yum.repos.d/
done

read -p “"请确认真机设置好时间同步，确认请按Enter " 

#设置时间同步
echo "server 192.168.4.254 iburst" >> /etc/chrony.conf
systemctl restart chronyd

#三台node 设置时间同步
for i in 10 11 12 13 14 15
do
	scp /etc/chrony.conf  root@192.168.4.$i:/etc/chrony.conf
done

read -p "请确认虚拟机已经添加三个磁盘,确认请按Enter "


#部署软件
yum -y install ceph-deploy
mkdir ceph-cluster
cd ceph-cluster/

#部署Ceph集群
ceph-deploy new node1 node2 node3

#给所有节点安装软件包
ceph-deploy install node1 node2 node3

#初始化所有节点的mon服务
ceph-deploy mon create-initial



#创建OSD
parted /dev/vdb mklabel gpt
parted /dev/vdb mkpart primary 1 50%
parted /dev/vdb mkpart primary 50% 100%
chown ceph.ceph /dev/vdb1
chown ceph.ceph /dev/vdb2

echo 'ENV{DEVNAME}=="/dev/vdb1",OWNER="ceph",GROUP="ceph"
ENV{DEVNAME}=="/dev/vdb2",OWNER="ceph",GROUP="ceph"' > /etc/udev/rules.d/70-vdb.rules

echo "parted  /dev/vdb  mklabel  gpt
parted  /dev/vdb  mkpart primary  1M  50%
parted  /dev/vdb  mkpart primary  50%  100%
chown  ceph.ceph  /dev/vdb1
chown  ceph.ceph  /dev/vdb2
"
read -p "请确认其他node 已经分区,方案在上面，复制就好，设置好权限，做完了请按Enter"


#所有node 设置永久磁盘规则
for i in 12 13
do
	scp /etc/udev/rules.d/70-vdb.rules root@192.168.4.$i:/etc/udev/rules.d/
done

#初始化清空磁盘数据
ceph-deploy disk zap node1:vdc node1:vdd

ceph-deploy disk zap node2:vdc node2:vdd

ceph-deploy disk zap node3:vdc node3:vdd

#创建OSD存储空间
ceph-deploy osd create  node1:vdc:/dev/vdb1  node1:vdd:/dev/vdb2

ceph-deploy osd create  node2:vdc:/dev/vdb1  node2:vdd:/dev/vdb2

ceph-deploy osd create  node3:vdc:/dev/vdb1  node3:vdd:/dev/vdb2

#验证
ceph -s
sleep 10

#查看存储池
#ceph osd lspools

#创建镜像
while :
do

	read -p "请必须属入一个名字来创建您的镜像,若不想创建直接按Enter： " demo
	read -p "请必须输入一个大小来定义您的镜像大小，若不想创建直接按Enter： " size

#创建镜像
#rbd create $demo  --image-feature  layering --size 10G

		if	[ -z  $demo ];then
			break
		else
			rbd create $demo --image-feature layering --size $size
		fi
done





















echo "去客户端安装client安装ceph-common软件
然后从node1 scp下载/etc/ceph/ceph.client.admin.keyring
与 /etc/ceph/ceph.conf 两个文件

最后用命令 rbd map $demo 发现镜像
接着去格式化就可以挂载使用了。"










