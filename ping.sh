#!/bin/bash
cecho(){
 echo -e "\033[$1m$2\033[0m"
}
for i in `seq 254`
do
   ping -c 4 -i 0.1 -W 1 176.4.11.$i &> /dev/null
    if  [ $? -eq 0 ];then
        cecho 32 "ip 176.4.11.$i 可以ping通" 
    else
        cecho 31 "ip 176.4.11.$i 不可以ping通"
    fi
done

