# Backup Zen
## Automated Database Backup Using Helm

This repository contains backup scripts for MySQL, MongoDB, and PostgreSQL databases based on best practices. These scripts perform automated backups on a daily and monthly basis, rotating backups for a specified number of times.


### Main features

- Helm: Quick, Reliable Deployment with Notifications on Success/Failure
- Full or individual backups from MySQL, PostgreSQL, and MongoDB.
- Skip specified databases in Full backup mode
- Specify the weekly backup day from (Monday-Sunday) and number of days/weeks to keep backups
- Sync dumped files with AWS S3/MinIO/Ceph object storage
- Read secret variables from kubernetes secrets or direct put them in values.yaml

### Getting Started

#### Prerequisites

##### Using Helm
- Helm and kubectl installed and configured
  

##### Using crontab
Before using these scripts, you will need to have the following installed on your system:

- MySQL client (for MySQL backups)
- MongoDB client (for MongoDB backups)
- PostgreSQL client (for PostgreSQL backups)
- AWS client with configured profiles
- AWS bucket as cloud storage
- Kubectl with associated kubeconfigs
- GNU tar
- Cron

#### Installation

1. Clone this repository to your local machine:

```bash
https://github.com/mrezachalak/db-backup
```

2. Configure the backup settings in the `config` files (e.g. [mysql_backup.config](https://github.com/mrezachalak/db-backup/blob/main/mysql_backup/mysql_backup.config))

3. Set the execution permission for the backup scripts:

```bash
find . -name "*.sh" -exec chmod +x {} \;
```

4. Schedule the backups using Cron. For example, to backup MySQL databases, add the following line to your crontab:
```bash
0 2 * * * /path/to/db-backup/mysql_backup/main.sh
0 3 * * * /path/to/db-backup/mongo_backup/main.sh
0 4 * * * /path/to/db-backup/pg_backup/main.sh

```

### Note

PostgreSQL backup scripts has been adapted with PostgresWiki
https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux

### Change Log

March 7th, 2023: [MongoDB backup](https://github.com/mrezachalak/db-backup/tree/main/mongo_backup) initial release

April 23th, 2023: MongoDB some typo fixed and some improvements has made in variable naming

April 23th, 2023:[MySQL backup](https://github.com/mrezachalak/db-backup/tree/main/mysql_backup) initial release

April 23th, 2023:[PostgreSQL backup](https://github.com/mrezachalak/db-backup/tree/main/pg_backup) initial release

August 10th, 2023: Dockerfile of postgres backup-zen client added

August 12th, 2023: Helm chart of postgres backup-zen added

### Licence
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](https://github.com/mrezachalak/db-backup/blob/main/LICENSE) file for details.
