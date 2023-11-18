#!/bin/bash
if [ -z "$1" ];then
    VERSION=latest
else
    VERSION="$1"
fi
SCRIPTPATH=$(cd ${0%/*} && pwd -P)

cd $SCRIPTPATH/mongo/
docker build . -t rezachalak/bzen-mongo:$VERSION
docker push rezachalak/bzen-mongo:$VERSION

cd $SCRIPTPATH/mysql/
docker build . -t rezachalak/bzen-mysql:$VERSION
docker push rezachalak/bzen-mysql:$VERSION

cd $SCRIPTPATH/pg/
docker build . -t rezachalak/bzen-pg:$VERSION
docker push rezachalak/bzen-pg:$VERSION
