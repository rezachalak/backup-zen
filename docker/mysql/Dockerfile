FROM mysql:8.0.34-debian

RUN apt-get update && apt-get install -y python3 python3-pip curl gzip
RUN pip install pymsteams  mysql-connector-python

# Which day to take the weekly backup from (1-7 = Monday-Sunday)
ENV DAY_OF_WEEK_TO_KEEP=5
# Number of days to keep daily backups
ENV DAYS_TO_KEEP=7
# How many weeks to keep weekly backups
ENV WEEKS_TO_KEEP=5
# Optional hostname and port to adhere to pg_hba policies.  Will default to "localhost" and 5432 if none specified.
# Will be read when oneByOne backup  enabled
ENV DB_HOST=localhost
ENV DB_PORT=5432
# Optional username to connect to database as. Will default to "postgres" if none specified.
# Will be read when oneByOne backup  enabled
ENV USERNAME=
ENV PASSWORD=
# List of strings to match against in database name, separated by space or comma, for which we only wish to skip
ENV SKIPPED_DATABASES=""
# Will be read when oneByOne backup  enabled
# Will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes"
ENV ENABLE_GLOBALS_BACKUPS=yes

ENV BACKUP_DIR=/backups
ENV TEAMS_NOTIFICATION=False
ENV SUCCEEDED_TEAMS_URL=""
ENV FAILED_TEAMS_URL=""

WORKDIR /app
COPY scripts/mysqldump.py .
COPY resources/creds.json .
COPY --chmod=0555 scripts/mysql_backup_rotated.sh .
COPY --chmod=0555 scripts/pymysql_backup_rotated.sh .

ENTRYPOINT []

CMD [/app/mysql_backup_rotated.sh]
