#!/bin/bash

if [ $# != 1 ] ; then
  echo -e "\e[1;33m!!!USEAGE: deploy.sh [CONFIG_FILE]\e[0m"
  exit 1
fi

echo -e "\e[1;33m## Check install envenvironment...\e[0m"
./prepare.sh >/dev/null
echo -e "\e[1;33m## Envenvironment prepare OK!\e[0m"

CONFIG_FILE=$1
LOGFILE_PATH="./install_log"
LOGLIST_FILE=".loglist"
SUCCESS_LOG="You can launch Cloud Foundry"
#MOD_LIST="nats hm9000 ccng uaa ha dea loggr gorouter"
MOD_LIST=`cat $CONFIG_FILE | shyaml get-value deploy`

#access nats_ip and domain

DOMAIN=`cat $CONFIG_FILE | shyaml get-value domain`
PASSWD=`cat $CONFIG_FILE | shyaml get-value password`
ORG=`cat $CONFIG_FILE | shyaml get-value org`


if [ "`cat $CONFIG_FILE | shyaml get-value deploy | grep -c "all"`" != 0 ];then
    echo -e "\e[1;32m == Install all mode in local.\e[0m"
    ./deploy_local.sh $DOMAIN $PASSWD $ORG
    exit 0
fi


NATS_IP=`cat $CONFIG_FILE | shyaml get-value component.nats.0.ip`

echo -e "\e[1;32m## It will install list module:\e[0m"

echo "------------------------------------------------"
echo "| NO. |        MOD       |         IP          |"
echo "------------------------------------------------"

count=0

for mod in $MOD_LIST
do
  if [ ! "`cat $CONFIG_FILE | grep -c "$mod"`" != 0 ];then
    continue
  fi

  MOD_NUM=`cat $CONFIG_FILE | shyaml get-value component.$mod | grep ip | wc -l`
  for k in `seq $MOD_NUM`
  do
    index=`expr $k - 1`
    ((count++))

    MOD_IP=`cat $CONFIG_FILE | shyaml get-value component.$mod.$index.ip`

    echo "| $count. |        $mod       | $MOD_IP |"
    echo "------------------------------------------------"
  done
done

echo -e "\e[1;33m## Generate install script...\e[0m"
#generate install.sh
./generate_install.sh $NATS_IP $DOMAIN $PASSWD $ORG
echo -e "\e[1;32m## Install script OK!\e[0m"

#deploy all module
touch $LOGLIST_FILE

for mod in $MOD_LIST
do
  if [ ! "`cat $CONFIG_FILE | grep -c "$mod"`" != 0 ];then
    echo "Not find $mod, skip!"
    continue
  fi

    MOD_NUM=`cat $CONFIG_FILE | shyaml get-value component.$mod | grep ip | wc -l`
    
    for k in `seq $MOD_NUM`
    do
      index=`expr $k - 1`
      MOD_IP=`cat $CONFIG_FILE | shyaml get-value component.$mod.$index.ip`
      MOD_PSW=`cat $CONFIG_FILE | shyaml get-value component.$mod.$index.psw` 
  
      echo "Deploying module $mod-$ipaddr: $k/$MOD_NUM"
      ./deploy_moudle.sh $mod $MOD_IP $MOD_PSW
      echo "$mod-$MOD_IP.log" >> $LOGLIST_FILE
    done
done

exit 0

#waiting for all processes start
for ((i=0; i<60; i++));
do
    LOGFILE=`cat $LOGLIST_FILE`

    for file in $LOGFILE
    do
	if [ -f $LOGFILE_PATH/$file ]; then
	    if grep -i "$SUCCESS_LOG" $LOGFILE_PATH/$file > /dev/null; then
	        sed -i '/'$file'/d' $LOGLIST_FILE
		echo "Module ${file%.log} deploy done."
	    fi
	fi
    done

    if [ ! -s $LOGLIST_FILE ]; then
	echo "All module deploy done!"
	break
    fi

    sleep 10
done

if [ -s $LOGLIST_FILE ]; then
    echo "10 minutes timeout for module deploy!"
fi

rm -rf $LOGLIST_FILE


