import os
from datetime import datetime
import json
import subprocess
import pymsteams
import sys

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

host = os.getenv('DB_HOST')
port = os.getenv('DB_PORT')
teamsNotif = os.getenv('TEAMS_NOTIFICATION')
succeededTeamsURL = os.getenv('SUCCEEDED_TEAMS_URL')
failedTeamsURL = os.getenv('FAILED_TEAMS_URL')

base_backup_dir = os.getenv('BACKUP_DIR')
if not os.path.exists(base_backup_dir):
    os.makedirs(base_backup_dir)

SUFFIX = sys.argv[1]
current_time = datetime.now().strftime("%Y-%m-%d_%H")
backup_dir = os.path.join(base_backup_dir,current_time+SUFFIX)
if not os.path.exists(backup_dir):
    os.makedirs(backup_dir)

with open('/app/creds.json', 'r') as file:
    content = json.loads(file.read())
SUCCESS=True
LOG='\n\nPostgreSQL backup started.   \n'
for db in content:
    target_file = os.path.join(backup_dir,str(db.get("database_name"))+"-dump.custom.in_progress")

    command = f'pg_dump -h {host} -U {db.get("username")} -d {db.get("database_name")} -p {port} -f {target_file}'
    output = subprocess.run(['bash', '-c', command], env={'PGPASSWORD': db.get("password")})
    if output.returncode != 0:
        SUCCESS=False
        LOG += f'   \nSomething went wrong while dumping: {db.get("database_name")}'
        print(bcolors.WARNING +f'Something went wrong while dumping: {db.get("database_name")}'+ bcolors.ENDC , output.stderr)
    else:
        os.rename(target_file, os.path.join(backup_dir,str(db.get("database_name"))+"-dump.custom"))
        print( bcolors.OKGREEN + f'Backup completed: {db.get("database_name")} database.')
        LOG += f'   \nBackup completed: {db.get("database_name")} database.'
LOG += '\n\nPostgreSQL backup finished.'
if teamsNotif:
    succeededJobsTeamsMessage = pymsteams.connectorcard(succeededTeamsURL)
    failedJobsTeamsMessage = pymsteams.connectorcard(failedTeamsURL)
if SUCCESS:
    if teamsNotif:
       succeededJobsTeamsMessage.title(f"RDS PostgreSQL dumps succeeded!")
       succeededJobsTeamsMessage.text(LOG)
       succeededJobsTeamsMessage.send()
    print( bcolors.OKGREEN + "Postgres dumps succeeded!!!" + bcolors.ENDC)
else:
    if teamsNotif:
        failedJobsTeamsMessage.title("One or more postgres database dumps failed!")
        failedJobsTeamsMessage.text(LOG)
        failedJobsTeamsMessage.send()
    print( bcolors.FAIL + "One or more postgres database dumps failed!!!" + bcolors.ENDC)
    raise (SystemExit)

