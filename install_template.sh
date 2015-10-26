#!/bin/bash
if [ $# != 2 ] ; then
  echo -e "\e[1;33m!!!USEAGE: install.sh [INSTALL_MODULE] [INDEX]\e[0m"
  exit 1;
fi

HOST_ADDR=10.0.0.12.host.addr
HOST_PASSWORD=host_password
HOST_LOGPATH=host_logpath

INSTALL_MODULE=$1
INDEX=$2

LOCAL_IP=`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`

echo -e "\e[1;32m == Begin install for $1 \e[0m"

sudo mkdir -p /var/vcap/dtdream/log

cd /var/vcap/dtdream


echo -e "\e[1;33m == downloading dtdream pass installer... \e[0m"
wget "http://10.168.111.185/blobstore/cf_installer_v2.tar.bz2" >/tmp/wget.log 2>&1
#cp /home/paas/cf_installer.tar.bz2 ./
echo -e "\e[1;32m == download ok! \e[0m"
tar xjf cf_installer_v2.tar.bz2
#rm -rf cf_installer.tar.bz2

cd cf_installer_v2

echo -e "\e[1;33m == Generate deploy manifest... \e[0m"

# 生成对应模块的部署配置
cp /tmp/deploy.yml manifests/deploy.yml

echo -e "\e[1;32m == deploy.yml ok! \e[0m"
echo -e "\e[1;33m == Now begin install... \e[0m"

DATE1=`date +%s%N|cut -c1-13`/1000

# 更新为aliyun的源，数度比较快
sudo sed -i 's/mirrors.163.com/mirrors.aliyun.com/g' /etc/apt/sources.list
# 清理apt缓存，解决apt-get update失败的错误
sudo rm -rf /var/lib/apt/lists/

# 解决source错误
sudo sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

INSTALL_LOG_FILE=/var/vcap/dtdream/log/${INSTALL_MODULE}_${LOCAL_IP}.log

export INSTALL_MODULES_LIST=$INSTALL_MODULE
export INSTALL_INDEX=$INDEX

./scripts/install.sh  $INSTALL_MODULE > $INSTALL_LOG_FILE 2>&1

unset INSTALL_MODULES_LIST
unset INSTALL_INDEX

DATE2=`date +%s%N|cut -c1-13`/1000

MIN=$(((${DATE2}-${DATE1})/60))
SEC=$(((${DATE2}-${DATE1})%60))

if [ "`cat $INSTALL_LOG_FILE | grep -c "You can launch Cloud Foundry"`" != 0 ];then
    echo -e "\e[1;33m == Install ok! Elapsed time: $MIN min $SEC s.\e[0m"
else
    echo -e "\e[1;31m !!! Something failed when install, check logs... \e[0m"
fi

echo -e "\e[1;33m == Now upload logs... \e[0m"
# 上传安装日志
./scripts/upload_log.sh $HOST_ADDR $HOST_PASSWORD $INSTALL_LOG_FILE $HOST_LOGPATH >/dev/null 2>&1

echo -e "\e[1;32m == Upload ok! \e[0m"

echo -e "\e[1;33m == Start monit... \e[0m"

sudo /var/vcap/bosh/bin/monit
sudo /var/vcap/bosh/bin/monit reload

MONIT_IP=`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | tail -n 1`
echo -e "\e[1;32m == Monit at http://$MONIT_IP:2822 \e[0m"

#sudo rm -rf /var/vcap/dtdream
rm -rf /tmp/install.sh
rm -rf /tmp/deploy.yml
rm -rf /var/vcap/dtdream

echo -e "\e[1;32m == Finish $INSTALL_MODULE install! \e[0m"
