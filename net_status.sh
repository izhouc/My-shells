#!/bin/bash
case $1 in
estab)
	ss -antp | awk '/^ESTAB/{x++}END{print x}';;
close_wait)
	ss -antp | awk '/^CLOSE-WAIT/{x++}END{print x}';;
time_wait)
	ss -antp | awk '/^TIME-WAIT/{x++}END{print x}';;
time_wait2)
	ss -antp | awk '/^TIME-WAIT2/{x++}END{print x}';;
esac
