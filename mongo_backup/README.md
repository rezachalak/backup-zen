# MongoDB Full Backup
## What is going to when this backup has ran?
Simply, the whole collections available in your mongodb will be backed up.

## How to use?
1. Fill out mongo_backup.config 
2. Run main.sh on your backup server
3. Then if succeeded Run `crontab -e` then add  '0 2 * * * /bin/bash /path/to/this/repo/mongo_backup/main.sh' to your crontabs
4. You can also use [healthcheck.io](https://healthchecks.io/) to get notification if anything went wrong, i.e. if it did not ran.
