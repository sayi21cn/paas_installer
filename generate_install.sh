#!/bin/bash

if [ $# != 1 ] ; then 
  echo -e "\e[1;33m!!!USEAGE: generate_install.sh [LOCAL_PASSWORD]\e[0m"
  exit 1; 
fi

LOCAL_IP=`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`
LOCAL_PASSWORD=$1
UPLOAD_PATH=$(pwd)/install_log

rm -rf $UPLOAD_PATH
mkdir $UPLOAD_PATH

cp ./install_template.sh ./install.sh

#生成本次部署的安装脚本
sed -i "s/10.0.0.12.host.addr/${LOCAL_IP}/g" ./install.sh
sed -i "s/host_password/${LOCAL_PASSWORD}/g" ./install.sh
sed -i "s:host_logpath:'${UPLOAD_PATH}':g" ./install.sh
