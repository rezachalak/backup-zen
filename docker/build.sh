#!/bin/bash
if [ -z "$1" ];then
    VERSION=latest
else
    VERSION="$1"
fi
SCRIPTPATH=$(cd ${0%/*} && pwd -P)

cd $SCRIPTPATH/mongo/
docker build . -t backupzen/mongo:$VERSION
docker push backupzen/mongo:$VERSION

cd $SCRIPTPATH/mysql/
docker build . -t backupzen/mysql:$VERSION
docker push backupzen/mysql:$VERSION

cd $SCRIPTPATH/pg/
docker build . -t backupzen/pg:$VERSION
docker push backupzen/pg:$VERSION
