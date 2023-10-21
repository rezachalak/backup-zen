#!/bin/bash

logFile=./logAndError
FAILED=false

###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $DB_HOST ]; then
	DB_HOST="localhost"
fi;

if [ ! $USERNAME ]; then
	USERNAME="root"
fi;

if [ ! $DB_PORT ]; then
	DB_PORT="3306"
fi;

###########################
#### START THE BACKUPS ####
###########################

function perform_backups()
{
	SUFFIX=$1
	FINAL_BACKUP_DIR=$BACKUP_DIR"`date +\%Y-\%m-\%d_\%H`$SUFFIX/"

	echo "Backup directory: $FINAL_BACKUP_DIR" | tee -a $logFile

	if ! mkdir -p $FINAL_BACKUP_DIR; then
		echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!" | tee -a $logFile 1>&2
		exit 1;
	fi;


	###########################
	###### FULL BACKUPS #######
	###########################


	echo -e "\n\nPerforming full backups" | tee -a $logFile
	echo -e "--------------------------------------------\n"

	# Get all database list first
	DBS="$(mysql -u $USERNAME -h $DB_HOST  --port=$DB_PORT -p$MYSQL_PASSWORD -Bse 'show databases')"

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
			echo "Backup of $db"

	        # do all inone job in pipe,
	        # connect to mysql using mysqldump for select mysql database
	        # and pipe it out to gz file in backup dir :)
            mysqldump --no-tablespaces -u $USERNAME -h $DB_HOST --port=$DB_PORT -p$PASSWORD $db | gzip -9 > $FILE.in_progress
	        if [ ${PIPESTATUS[0]} != 0 ]; then
	                echo "\n[ERROR] Failed to produce backup database $db" | tee -a logFile 1>&2
					FAILED=true
	        else
					echo "\nBackup of $db done" | tee -a $logFile
	                mv $FILE.in_progress $FILE
	        fi

	    fi
	done

	if $FAILED
	then
		echo -e "\n\nAll Database backups completed, but one or more backups failed!" | tee -a $logFile
		output_json=$(printf '{"title": "Backups failed!","text":  "%s  <pre>Pod name: %s\nDatabase Host address: %s</pre>"}' "$(cat /app/logAndError)" $KUBERNETES_POD_NAME $DB_HOST)
		curl -H 'Content-Type: application/json' -d "${output_json}" $FAILED_TEAMS_URL
		exit 1;
	else
		echo -e "\n\nAll database backups completed!" | tee -a $logFile
		output_json=$(printf '{"title": "Backups successfully done!","text":  "%s  <pre>Pod name: %s\nDatabase Host address: %s</pre>"}' "$(cat /app/logAndError)" $KUBERNETES_POD_NAME $DB_HOST)
		curl -H 'Content-Type: application/json' -d "${output_json}" $SUCCEEDED_TEAMS_URL
		exit 0;
	fi
}

# MONTHLY BACKUPS

DAY_OF_MONTH=`date +%d`

if [ $DAY_OF_MONTH -eq 1 ];
then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'

	perform_backups "-monthly"
fi

# WEEKLY BACKUPS

DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if [ $DAY_OF_WEEK = $DAY_OF_WEEK_TO_KEEP ];
then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'

	perform_backups "-weekly"
fi

# DAILY BACKUPS

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"
