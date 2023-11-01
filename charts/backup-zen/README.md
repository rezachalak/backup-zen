# Backup-Zen
Backup-Zen is a Database Backup Solution Using Helm

[Github Repo](https://github.com/rezachalak/backup-zen)

[Installation](https://github.com/rezachalak/backup-zen#using-helm)

[Web Site](https://rezachalak.github.io/backup-zen/)

[Documentation](https://artifacthub.io/packages/helm/bzen/backup-zen)

<!-- [Mailing List]() -->
[Bug Reports](https://github.com/rezachalak/backup-zen/issues)
<!-- [Donate]() -->
<!-- [Scripting API]() -->

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

    helm repo add bzen https://rezachalak.github.io/backup-zen/

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
bzen` to see the charts.

To install the backup-zen chart:

    helm install my-backup-zen bzen/backup-zen

To uninstall the chart:

    helm delete my-backup-zen  


## Installation
1. Add Backup-Zen chart repository.
```
helm repo add bzen https://rezachalak.github.io/backup-zen/
```

2. Update local Backup-Zen chart information from chart repository.
```
helm repo update
```

3. Install Backup-Zen chart.
- With Helm 2, the following command will create the `backup-zen` namespace and install the Backup-Zen chart together.
```
helm install bzen/backup-zen --name bzen --namespace backup-zen
```
- With Helm 3, the following commands will create the `backup-zen` namespace first, then install the Backup-Zen chart.

```
kubectl create namespace backup-zen
helm install bzen bzen/backup-zen --namespace backup-zen
```

## Uninstallation

With Helm 2 to uninstall Backup-Zen.
```
helm delete bzen --purge
```

With Helm 3 to uninstall Backup-Zen.
```
helm uninstall bzen -n backup-zen
kubectl delete namespace backup-zen
```

## Values

The `values.yaml` contains items used to tweak a deployment of this chart.

### General Settings
#### Backup Type
Select one of these two types:

`oneByOne`: preparing databaseName, username and password for each database as an array in oneByOne.creds must be provided: 

 credsSecretName is the name of the secret where the database credentials are stored (can be used instead of oneByOne.creds)

`credsSecretName: mycreds-secret`

 This secret must contain: `creds.json`
```
 creds.json: 
[
    {
    "database_name": "",
    "username": "",
    "password": "" 
    }
    ,...
]
```
Or in `values.yaml`:
```
  creds:
    - database_name: db1
      username: user1
      password: password1
    - database_name: db2
      username: user2
      password: password2
```

`adminUser`: admin user credentials in `adminUser.username` and `adminUser.password` must be provided

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| databaseType | string | `"MongoDB"` | Available db Types: PostgreSQL, MySQL & MongoDB|
| hostname | string | `"mydb.rds.amazonaws.com"` | Database Host Address |
| port | string | `"54325"` | Database Port |
| credentialType | string | `"oneByOne"` | Select one of these two types: oneByOne OR adminUser |
| global.namespace | string | `"maintenance"` |  |
| global.createNamespace | string | `"true"` |  |
| global.rotation | string | `"true"` |  |
| global.rotation_config.dayOfWeekToKeep | string | `"5"` | Which day to take the weekly backup from (1-7 = Monday-Sunday) |
| global.rotation_config.daysToKeep | string | `"7"` | Number of days to keep daily backups |
| global.rotation_config.weeksToKeep | string | `"5"` | How many weeks to keep weekly backups |
| global.teamsNotification | string | `"false"` |  |
| global.succeededTeamsURL | string | `"https://myorg.webhook.office.com/webhookb1/blob-blob-blob"` |  |
| global.failedTeamsURL | string | `"https://myorg.webhook.office.com/webhookb2/blob-blob-blob"` |  |

### Credentials Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminUser.username | string | `""` |  |
| adminUser.password | string | `""` |  |
| oneByOne.credsSecretName | string | `""` | the secret where the database credentials are stored (can be used instead of oneByOne.creds |
| oneByOne.creds | list(map) | `[{"database_name": "db1", "username": "u1", "password": "p1"}]`|  |

### Cronjob Scheduling Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cronjob.pullPolicy | string | `"Always"` |  |
| cronjob.imagePullSecrets | list(string) | `"[]"` |  |
| cronjob.restartPolicy | string | `"Never"` |  |
| cronjob.resources.requests.cpu | string | `"1"` |  |
| cronjob.resources.requests.memory | string | `"1Gi"` |  |
| cronjob.resources.limits.cpu | string | `"2"` |  |
| cronjob.resources.limits.memory | string | `"2Gi"` |  |
| cronjob.schedule | string | `"0 0 * * *"` |  |
| cronjob.failedJobsHistoryLimit | string | `""` |  |
| cronjob.successfulJobsHistoryLimit | string | `""` |  |
| cronjob.storage.createPVC | string | `""` |  |
| cronjob.storage.PVCName | string | `""` |  |
| cronjob.storage.storageClass | string | `""` |  |
| cronjob.storage.accessMode | string | `""` |  |
| cronjob.storage.PVCSize | string | `""` |  |

### Upload To objectStorage Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backupUpload.active | string | `"false"` |  |
| backupUpload.objectStorageType | string | `"AWS_S3"` | Supported objectStorages are: MinIO and AWS_S3 |
| backupUpload.objectStorageSecretName | string | `""` | the name of the secret where the credentials of object storage is stored. |
| backupUpload.AWS_S3.AWS_ACCESS_KEY_ID | string | `""` |  |
| backupUpload.AWS_S3.AWS_DEFAULT_REGION | string | `"us-west-1"` |  |
| backupUpload.AWS_S3.AWS_SECRET_ACCESS_KEY | string | `""` |  |
| backupUpload.AWS_S3.BUCKET_NAME | string | `"backupzen-s3"` |  |
| backupUpload.MINIO.MINIO_ACCESS_KEY_ID | string | `""` |  |
| backupUpload.MINIO.MINIO_URL | string | `"http://localhost:9000"` |  |
| backupUpload.MINIO.MINIO_SECRET_ACCESS_KEY | string | `""` |  |
| backupUpload.MINIO.BUCKET_NAME | string | `""` |  |
| backupUpload.MINIO.O | string | `"backupzen-minio"` |  |


---
Please see [link](https://github.com/rezachalak/backup-zen) for more information.