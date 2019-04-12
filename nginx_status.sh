#!/bin/bash
case $1 in
accepts)
        curl -s http://127.0.0.1/status | awk 'NR==3{print $2}';;
active)
        curl -s http://127.0.0.1/status | awk '/Active/{print $NF}';;
waiting)
        curl -s http://127.0.0.1/status | awk '/Waiting/{print $NF}';;
esac
