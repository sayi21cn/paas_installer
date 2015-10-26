#!/bin/bash

if [ $# != 4 ] ; then 
  echo -e "\e[1;33m!!!USEAGE: deploy_node.sh [MODULE] [INDEX] [DEPLOY_ADDR] [ROOT_PASSWORD]\e[0m"
  exit 1; 
fi

if [ ! -f "./install.sh" ]; then
  echo -e "\e[1;31m!!!Please run generate_install.sh first!\e[0m"
fi

echo "deploy $1 $2 $3"

MODULE=$1
INDEX=$2
DEPLOY_ADDR=$3
ROOT_PASSWORD=$4

#将安装脚本push到目标地址
./sync_file.sh $DEPLOY_ADDR $ROOT_PASSWORD ./install.sh /tmp

#同步配置文件
./sync_file.sh $DEPLOY_ADDR $ROOT_PASSWORD ./deploy.yml /tmp

#执行安装命令，在后台运行，完成后会将安装日志push回本地
./sync_cmd.sh $DEPLOY_ADDR $ROOT_PASSWORD "cd /tmp; nohup ./install.sh $MODULE $INDEX >/var/install.log &"

