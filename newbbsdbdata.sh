#!/bin/bash


innobackupex --user root --password tarena --databases="bbsdb"  --incremental /mybakdata/new-`date +%F`  --incremental-basedir="/mybakdata/bbsdbbak-`date +%F`" --no-timestamp


