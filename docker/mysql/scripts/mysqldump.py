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
k8sPodName = os.getenv('KUBERNETES_POD_NAME')

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
LOG='\n\nMySQL backup started.   \n'
for db in content:
    target_file = os.path.join(backup_dir,str(db.get("database_name"))+"-dump.gz.in_progress")
    command = f'mysqldump --no-tablespaces -u {db.get("username")} -h {host} --port={port} -p{db.get("password")} {db.get("database_name")} | gzip -9 > {target_file}'
    output = subprocess.run(['bash', '-c', command])
    if output.returncode != 0:
        SUCCESS=False
        LOG += f'   \nSomething went wrong while dumping: {db.get("database_name")}'
        print(bcolors.WARNING +f'Something went wrong while dumping: {db.get("database_name")}'+ bcolors.ENDC , output.stderr)
    else:
        os.rename(target_file, os.path.join(backup_dir,str(db.get("database_name"))+"-dump.gz"))
        print( bcolors.OKGREEN + f'Backup completed: {db.get("database_name")} database.')
        LOG += f'   \nBackup completed: {db.get("database_name")} database.'
LOG += f'\n\nBackups successfully done!\n\n<pre>Pod name: {k8sPodName}\nDatabase Host Address: {host}</pre>'
if teamsNotif:
    succeededJobsTeamsMessage = pymsteams.connectorcard(succeededTeamsURL)
    failedJobsTeamsMessage = pymsteams.connectorcard(failedTeamsURL)
if SUCCESS:
    if teamsNotif:
       succeededJobsTeamsMessage.title(f"Database dumps succeeded!")
       succeededJobsTeamsMessage.text(LOG)
       succeededJobsTeamsMessage.send()
    print( bcolors.OKGREEN + "Dumps succeeded!!!" + bcolors.ENDC)
else:
    if teamsNotif:
        failedJobsTeamsMessage.title("One or more database dumps failed!:(")
        failedJobsTeamsMessage.text(LOG)
        failedJobsTeamsMessage.send()
    print( bcolors.FAIL + "One or more database dumps failed!!!" + bcolors.ENDC)
    raise (SystemExit)

