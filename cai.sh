#!/bin/bash
num=$[RANDOM%100+1]
x=0
while : 
do
	read -p "请输入100以内的数字你猜: " cai
		let x++
		if	[ $cai -gt $num ];then
				echo "你猜大了"
		elif
			[ $cai -lt $num ];then
				echo "你猜小了"
		else
				echo "你猜对了"
				echo "你一共猜了$x 次"
				exit
		fi
done
