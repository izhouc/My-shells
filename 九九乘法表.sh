#!/bin/bash
for  i  in  `seq 9`
do
	for n in `seq $i`
	do
		echo -n "$i*$n=$[i*n] "
	done
	echo
done
