#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "start.sh <ip address> <node id>"
    echo "at the same path as directory nodetemplate"
    exit
fi

rm ./node$2 -r
mkdir ./node$2
cp ./nodetemplate/* ./node$2/
cd ./node$2

sed -i 's/IPADDRESS/'$1'/g' *
sed -i 's/NODEID/'$2'/g' *

sh telnet_none_filtering.sh


