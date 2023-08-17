#!/bin/bash
set -e
BACKUP_DIR=/home/avidadm/db-backups/mysql
BACKUP_TIME=$(date +%Y%m%d%H%M)

export MYSQL_ROOT_PASSWORD=$(kubectl get secret ir-mysql-credentials --namespace devops-team -o jsonpath="{.data.root}" | base64 --decode)
# log files

SCRIPTPATH=$(cd ${0%/*} && pwd -P)
$SCRIPTPATH/mysql_backup_rotated.sh 2>&1 | tee -a $LOG


echo "aws sync starting" | tee -a $LOG
if ! /usr/local/bin/aws s3 sync $BACKUP_DIR  s3://iran-db-backup/mysql --delete --profile s3irandbbackup > $LOG
then
  cat $LOG | mail -s "Iran mysql sync failed" alerts@avidcloud.io
  exit 1
else
  echo "aws sync succeeded" | tee -a $LOG
fi

date | tee -a $LOG

