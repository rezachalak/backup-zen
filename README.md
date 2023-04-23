# Database Backup Scripts

This repository contains backup scripts for MySQL, MongoDB, and PostgreSQL databases. These scripts perform automated backups on a daily and monthly basis, rotating backups for a specified number of times.

## Getting Started

### Prerequisites

Before using these scripts, you will need to have the following installed on your system:

- MySQL client (for MySQL backups)
- MongoDB client (for MongoDB backups)
- PostgreSQL client (for PostgreSQL backups)
- GNU tar
- Cron

### Installation

1. Clone this repository to your local machine:

```bash
https://github.com/mrezachalak/db-backup
```

2. Configure the backup settings in the `config` files (e.g. [mysql_backup.config](https://github.com/mrezachalak/db-backup/blob/main/mysql_backup/mysql_backup.config))

3. Set the execution permission for the backup scripts:

```bash
chmod +x mysql-backup.sh mongodb-backup.sh postgresql-backup.sh
```

4. Schedule the backups using Cron. For example, to backup MySQL databases, add the following line to your crontab:
```bash
0 2 * * * /path/to/db-backup/mysql_backup/main.sh daily
```

### Change Log

March 7th: [MongoDB backup](https://github.com/mrezachalak/db-backup/tree/main/mongo_backup) initial release

April 23th: MongoDB some typo fixed and some improvements has made in variable naming

April 23th:[MySQL backup](https://github.com/mrezachalak/db-backup/tree/main/mysql_backup) initial release

### Licence
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](https://github.com/mrezachalak/db-backup/blob/main/LICENSE) file for details.
