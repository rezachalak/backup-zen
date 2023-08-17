FROM mongo:5.0.20-rc1

RUN apt-get update && apt-get install -y python3 python3-pip curl gzip
RUN pip install pymsteams  mongo-connector

# Which day to take the weekly backup from (1-7 = Monday-Sunday)
ENV DAY_OF_WEEK_TO_KEEP=5
# Number of days to keep daily backups
ENV DAYS_TO_KEEP=7
# How many weeks to keep weekly backups
ENV WEEKS_TO_KEEP=5
# Optional hostname and port to adhere to pg_hba policies.  Will default to "localhost" and 5432 if none specified.
# Will be read when oneByOne backup  enabled
ENV DB_HOST=localhost
ENV DB_PORT=27017
# Optional username to connect to database as. Will default to "root" if none specified.
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
COPY scripts/mongodump.py .
COPY resources/creds.json .
COPY --chmod=0555 scripts/mongo_backup_rotated.sh .
COPY --chmod=0555 scripts/pymongo_backup_rotated.sh .

ENTRYPOINT []

CMD [/app/mongo_backup_rotated.sh]
