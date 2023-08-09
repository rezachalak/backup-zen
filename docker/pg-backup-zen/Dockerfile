FROM postgres:latest

RUN apt-get update && apt-get install -y python3 python3-psycopg2 python3-pip
RUN pip install pymsteams --break-system-packages

ENV DAY_OF_WEEK_TO_KEEP=5
ENV DAYS_TO_KEEP=7
ENV WEEKS_TO_KEEP=5
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV BACKUP_DIR=/backups
ENV TEAMS_NOTIFICATION=False
ENV SUCCEEDED_TEAMS_URL=""
ENV FAILED_TEAMS_URL=""

WORKDIR /app
COPY scripts/pgdump.py .
COPY resources/creds.json .
COPY --chmod=0500 scripts/pypg_backup_rotated.sh .
COPY --chmod=0500 scripts/pg_backup_rotated.sh .

ENTRYPOINT []

CMD [/app/pypg_backup_rotated.sh]
