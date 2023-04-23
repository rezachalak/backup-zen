#!/bin/bash
set -e
BACKUP_TIME=$(date +%Y%m%d%H%M)
AWS_COMMAND=$(which aws)
###########################
####### LOAD CONFIG #######
###########################

while [ $# -gt 0 ]; do
        case $1 in
                -c)
                        CONFIG_FILE_PATH="$2"
                        shift 2
                        ;;
                *)
                        ${ECHO} "Unknown Option \"$1\"" 1>&2
                        exit 2
                        ;;
        esac
done

if [ -z $CONFIG_FILE_PATH ] ; then
        SCRIPTPATH=$(cd ${0%/*} && pwd -P)
        CONFIG_FILE_PATH="${SCRIPTPATH}/mongo_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
        echo "Could not load config file from ${CONFIG_FILE_PATH}" 1>&2
        exit 1
fi

source "${CONFIG_FILE_PATH}"


###########################
####### INIT CONFIG #######
###########################

if $CREDENTIALS_IN_K8S; then
        export KUBECONFIG=$CREDENTIALS_KUBECONFIG
        export PG_ROOT_PASSWORD=$(kubectl get secret $DB_CRED_SECRET --namespace $CREDENTIAL_NAMESPACE -o jsonpath="{.data.password}" | base64 --decode)
fi

# Log files
mkdir -p $BACKUP_DIR/logs
LOG=$BACKUP_DIR/logs/log-$BACKUP_TIME.txt
echo \n\n\n >> $LOG
date | tee -a $LOG
echo \n >> $LOG
ps 2>&1 | tee -a $LOG


###########################
###### START PROCESS ######
###########################

# Port forward to postgresql statefulset on k8s cluster
if $K8S_PG; then
        export KUBECONFIG=$PG_KUBECONFIG
        kubectl port-forward statefulset/$PG_STATEFULSET_NAME -n $PG_NAMESPACE $PORT:$PG_STATEFULSET_PORT &
        pidofkubectl=$!
fi


# run backup process
SCRIPTPATH=$(cd ${0%/*} && pwd -P)
$SCRIPTPATH/pg_backup_rotated.sh

if $K8S_PG; then
        kill -9 $pidofkubectl
fi

###########################
######  SYNC WITH S3 ######
###########################

##### Copy backups to AWS S3 bucket #####
echo "aws sync starting" | tee -a $LOG
$AWS_COMMAND s3 sync $BACKUP_DIR  s3://$S3_BACKUP_BUCKET/postgresql --delete --profile $AWS_PROFILE 2>&1 | tee -a $LOG

echo "aws sync success" |tee -a $LOG
date | tee -a $LOG
echo "Postgresql backups has synced successfully" | mail -s "Postgresql sync success" $NOTIFICATION_EMAIL_ADDRESS