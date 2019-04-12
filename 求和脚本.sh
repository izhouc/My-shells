#!/bin/bash
sum=0
while :
do
	read -p "请输入需要求和的数字,【0表示结束】： " x
	if [ $x -eq 0 ];then
	break
	else
	   sum=$[sum+x]
	fi
done
echo "总和是： $sum"
