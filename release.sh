#!/bin/bash
if [ $# != 1 ] ; then
  echo -e "\e[1;33m!!!USEAGE: release.sh [FILENAME]\e[0m"
  exit 1;
fi

FILENAME=$1

rm -rf $FILENAME.tar.bz2
tar cjvf $FILENAME.tar.bz2 $FILENAME >/dev/null

FILE=$FILENAME.tar.bz2
REMOTE_IP=10.168.111.185
REMOTE_PATH=/home/www/blobstore
PASSWD="DtDream0209"

if ! (which expect); then
    sudo apt-get install -y expect
fi

expect -c "
spawn rsync $FILE root@${REMOTE_IP}:$REMOTE_PATH
expect {
        \"*assword\" {set timeout 300; send \"${PASSWD}\r\";}
        \"yes/no\" {send \"yes\r\"; exp_continue;}
          }
expect eof
"
