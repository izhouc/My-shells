#!/bin/bash
time=`date +%R`
if [ $# -eq 0 ];then
	echo "请添加图片"
	exit 1
fi
mv /var/lib/libvirt/images/tedu-wallpaper-2018.png  /var/lib/libvirt/images/tedu-wallpaper-${time}.bak.png 
cp $1  /var/lib/libvirt/images/tedu-wallpaper-2018.png
echo "请按ALT+F2，再输入小r，回车即可"
#sleep 2
#startx
