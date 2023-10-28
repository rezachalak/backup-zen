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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| databaseType | string | `"MongoDB"` | Database Type |
| hostname | string | `"mydb.rds.amazonaws.com"` | Database Host Address |
|  | string | `""` |  |


### Cronjob Scheduling Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
|  | string | `""` |  |
|  | string | `""` |  |

### Upload To objectStorage Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
|  | string | `""` |  |


---
Please see [link](https://github.com/rezachalak/backup-zen) for more information.