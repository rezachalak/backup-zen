#!/bin/bash

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
        CONFIG_FILE_PATH="${SCRIPTPATH}/mysql_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
        echo "Could not load config file from ${CONFIG_FILE_PATH}" 1>&2
        exit 1
fi

source "${CONFIG_FILE_PATH}"

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ] ; then
	echo "This script must be run as $BACKUP_USER. Exiting." 1>&2
	exit 1
fi


###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $HOSTNAME ]; then
	HOSTNAME="localhost"
fi;

if [ ! $USERNAME ]; then
	USERNAME="root"
fi;


###########################
#### START THE BACKUPS ####
###########################

function perform_backups()
{
	SUFFIX=$1
	FINAL_BACKUP_DIR=$BACKUP_DIR"`date +\%Y-\%m-\%d`$SUFFIX/"

	echo "Making backup directory in $FINAL_BACKUP_DIR"

	if ! mkdir -p $FINAL_BACKUP_DIR; then
		echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!" 1>&2
		exit 1;
	fi;


	###########################
	###### FULL BACKUPS #######
	###########################


	echo -e "\n\nPerforming full backups"
	echo -e "--------------------------------------------\n"

	# Get all database list first
	DBS="$(mysql -u $USERNAME -h $HOSTNAME -p$MYSQL_ROOT_PASSWORD -Bse 'show databases')"

	for db in $DBS
	do
	    skipdb=-1
	    if [ "$SKIPPED_DATABASES" != "" ];
	    then
	        for i in $SKIPPED_DATABASES
	        do
	            [ "$db" == "$i" ] && skipdb=1 || :
	        done
	    fi

	    if [ "$skipdb" == "-1" ] ; then
	        FILE="$FINAL_BACKUP_DIR/$db.gz"
	        # do all inone job in pipe,
	        # connect to mysql using mysqldump for select mysql database
	        # and pipe it out to gz file in backup dir :)
                mysqldump -u $USERNAME -h $HOSTNAME --port=3306 -p$MYSQL_ROOT_PASSWORD $db | gzip -9 > $FILE.in_progress
	        if [ $? != 0 ]; then
	                echo "[!!ERROR!!] Failed to produce backup database $db"
	        else
	                mv $FILE.in_progress $FILE
	        fi

	    fi
	done


	echo -e "\nAll database backups complete!"
}

# MONTHLY BACKUPS

DAY_OF_MONTH=`date +%d`

if [ $DAY_OF_MONTH -eq 1 ];
then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'

	perform_backups "-monthly"

	exit 0;
fi

# WEEKLY BACKUPS

DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if [ $DAY_OF_WEEK = $DAY_OF_WEEK_TO_KEEP ];
then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'

	perform_backups "-weekly"

	exit 0;
fi

# DAILY BACKUPS

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"
