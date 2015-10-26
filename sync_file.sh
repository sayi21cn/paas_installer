#!/bin/sh

if [ $# != 4 ] ; then
  echo -e "\e[1;33m!!!USEAGE: sync_file.sh [REMOTE_IP] [PASSWD] [FILE] [REMOTE_PATH]\e[0m"
  exit 1;
fi

REMOTE_IP=$1
PASSWD=$2
FILE=$3
REMOTE_PATH=$4

if ! (which expect); then
    sudo apt-get install -y expect
fi

# rsync file
expect -c "
spawn rsync $FILE root@${REMOTE_IP}:$REMOTE_PATH
expect { 
        \"*assword\" {set timeout 300; send \"${PASSWD}\r\";} 
        \"yes/no\" {send \"yes\r\"; exp_continue;} 
          }
expect eof
"
