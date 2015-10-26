#!/bin/sh

if [ $# != 3 ] ; then
  echo -e "\e[1;33m!!!USEAGE: sync_file.sh [REMOTE_IP] [PASSWD] [CMD]\e[0m"
  exit 1;
fi

REMOTE_IP=$1
PASSWD=$2
CMD=$3

if ! (which expect); then
    sudo apt-get install -y expect
fi

expect -c"
spawn ssh root@${REMOTE_IP} \"$CMD\" 
expect { 
    \"*assword\" {set timeout -1; send \"$PASSWD\r\";} 
    \"yes/no\" {send \"yes\r\"; exp_continue;} 
      } 
expect eof
"
