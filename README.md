# Backup-Zen
Backup-Zen is a Database Backup Solution Using Helm


## Main features
- Deploy on K8s using Helm
- Specify the type of database: MySQL, PostgreSQL, and MongoDB
- Set backup strategy: oneByOne or adminUser
- Determine whether to deploy on Object Storage (S3 and MinIO are supported) or not 
- Give Notifications on MSTeams for Fail/Success backup and upload
- Retention period: days and weeks to keep, and specify the desired day of the week for performing backups

## Getting Started

### Prerequisites
- A kubernetes cluster
- Read access to database
- Helm and kubectl installed and configured

### Using Helm

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add bzen https://backupzen.github.io/helm-charts

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
bzen` to see the charts.

To install the backup-zen chart:

    helm install my-backup-zen bzen/backup-zen

To uninstall the chart:

    helm delete my-backup-zen  

### Change Log

March 7th, 2023: [MongoDB backup](https://github.com/mrezachalak/db-backup/tree/main/mongo_backup) initial release

April 23th, 2023: MongoDB some typo fixed and some improvements has made in variable naming

April 23th, 2023:[MySQL backup](https://github.com/mrezachalak/db-backup/tree/main/mysql_backup) initial release

April 23th, 2023:[PostgreSQL backup](https://github.com/mrezachalak/db-backup/tree/main/pg_backup) initial release

August 10th, 2023: Dockerfile of postgres backup-zen client added

August 12th, 2023: Helm chart of postgres backup-zen added

October 21th, 2023: First release of helm ( version 0.1.0 )

### Licence
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](https://github.com/rezachalak/db-backup/blob/main/LICENSE) file for details.
