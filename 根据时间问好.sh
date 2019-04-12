#!/bin/bash
time=`date +%H`
if	[ $time -le 12 ];then
	echo "爸爸，早上好"
elif
	[ $time -ge 18 ];then
	echo "爸爸，晚上好"
else
	echo "爸爸，下午好"
fi



