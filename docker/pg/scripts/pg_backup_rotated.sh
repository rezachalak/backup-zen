#!/bin/bash

logFile=./logAndError
FAILED=false
###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $DB_HOST ]; then
	DB_HOST="localhost"
fi;

if [ ! $DB_PORT ]; then
	DB_PORT=5432
fi;

if [ ! $USERNAME ]; then
	USERNAME="postgres"
fi;

PGPASSWORD=$PASSWORD

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

	#######################
	### GLOBALS BACKUPS ###
	#######################

	echo -e "\n\nPerforming globals backup"
	echo -e "--------------------------------------------\n"

	if [ $ENABLE_GLOBALS_BACKUPS = "yes" ]
	then
		    echo "Globals backup" | tee -a $logFile

		    set -o pipefail
		    if ! pg_dumpall -g -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" | gzip > $FINAL_BACKUP_DIR"globals".sql.gz.in_progress; then
		            echo "[ERROR] Failed to produce globals backup" | tee -a $logFile 1>&2
					FAILED=true
		    else
		            mv $FINAL_BACKUP_DIR"globals".sql.gz.in_progress $FINAL_BACKUP_DIR"globals".sql.gz
		    fi
		    set +o pipefail
	else
		echo "None"
	fi


	###########################
	### SCHEMA-ONLY BACKUPS ###
	###########################

	for SCHEMA_ONLY_DB in ${SCHEMA_ONLY_LIST//,/ }
	do
	        SCHEMA_ONLY_CLAUSE="$SCHEMA_ONLY_CLAUSE or datname ~ '$SCHEMA_ONLY_DB'"
	done

	SCHEMA_ONLY_QUERY="select datname from pg_database where false $SCHEMA_ONLY_CLAUSE order by datname;"

	echo -e "\n\nPerforming schema-only backups"
	echo -e "--------------------------------------------\n"

	SCHEMA_ONLY_DB_LIST=`psql -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" -At -c "$SCHEMA_ONLY_QUERY" postgres`

	echo -e "The following databases were matched for schema-only backup:\n${SCHEMA_ONLY_DB_LIST}\n"

	for DATABASE in $SCHEMA_ONLY_DB_LIST
	do
	        echo "Schema-only backup of $DATABASE" | tee -a $logFile
		set -o pipefail
	        if ! pg_dump -Fp -s -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz.in_progress; then
	                echo "[ERROR] Failed to backup database schema of $DATABASE" | tee -a $logFile 1>&2
					FAILED=true
	        else
	                mv $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz
	        fi
	        set +o pipefail
	done


	###########################
	###### FULL BACKUPS #######
	###########################

	for SCHEMA_ONLY_DB in ${SCHEMA_ONLY_LIST//,/ }
	do
		EXCLUDE_SCHEMA_ONLY_CLAUSE="$EXCLUDE_SCHEMA_ONLY_CLAUSE and datname !~ '$SCHEMA_ONLY_DB'"
	done

	FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $EXCLUDE_SCHEMA_ONLY_CLAUSE order by datname;"

	echo -e "\n\nPerforming full backups" | tee -a $logFile
	echo -e "--------------------------------------------\n"

	for DATABASE in `psql -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
	do
		if [ $ENABLE_PLAIN_BACKUPS = "yes" ]
		then
			echo "\nPlain backup of $DATABASE" | tee -a $logFile
			set -o pipefail
			
			if ! pg_dump -Fp -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress; then
				echo "\n[ERROR] Failed to produce plain backup database $DATABASE" | tee -a $logFile 1&2
				FAILED=true

			else
				echo "\n\nPlain backup of $DATABASE done" | tee -a $logFile
				mv $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE".sql.gz
			fi
			set +o pipefail

		fi

		if [ $ENABLE_CUSTOM_BACKUPS = "yes" ]
		then
			echo "\nCustom backup of $DATABASE" | tee -a $logFile

			if ! pg_dump -Fc -h "$DB_HOST" -p "$DB_PORT" -U "$USERNAME" "$DATABASE" -f $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress; then
				echo "\n[ERROR] Failed to produce custom backup database $DATABASE" | tee -a $logFile 1>&2
				FAILED=true
			else
				mv $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress $FINAL_BACKUP_DIR"$DATABASE".custom
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
