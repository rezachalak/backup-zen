{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "backup-zen.name" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" -}}

{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backup-zen.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backup-zen.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create backup Configmap Name.
*/}}
{{- define "backup-zen.backupConfigName" -}}
{{ template "backup-zen.name" . }}-backup-config
{{- end -}}

{{/*
Create backup credentials secret Name.
*/}}
{{- define "backup-zen.backupCredsSecretName" -}}
{{ template "backup-zen.name" . }}-backup-creds
{{- end -}}


{{/*
Create backup object storage secret Name.
*/}}
{{- define "backup-zen.objectStorageSecretName" -}}
{{ template "backup-zen.name" . }}-object-storage-creds
{{- end -}}

{{/*
Create object storage uploader image.
*/}}
{{- define "backup-zen.uploaderImage" -}}
{{- if eq .Values.backupUpload.ObjectStorageType "AWS_S3" -}}
amazon/aws-cli:2.13.6
{{- else if eq .Values.backupUpload.ObjectStorageType "MinIO" -}}
minio/mc
{{- end -}}
{{- end -}}


{{/*
Create backup directory
*/}}
{{- define "backup-zen.backupDirectory" -}}
/backups
{{- end -}}

{{/*
Create namespace name
*/}}
{{- define "backup-zen.namespace" -}}
    {{- if .Values.global.namespace -}}
        {{- .Values.global.namespace -}}
    {{- else if .Values.global.createNamespace -}}
        {{- fail "namespace is missing in values file" -}}
    {{- else -}}
        default
    {{- end -}}
{{- end -}}

{{/*
Create Dumper image address
*/}}
{{- define "backup-zen.cronjob.dumper.image" -}}
    {{- if .Values.cronjob.image -}}
        {{- .Values.cronjob.image -}}
    {{- else if eq .Values.databaseType "PostgreSQL" -}}
        rezachalak/bzen-pg:{{ .Chart.AppVersion }}
    {{- else if eq .Values.databaseType "MySQL" -}}
        rezachalak/bzen-mysql:{{ .Chart.AppVersion }}
    {{- else if eq .Values.databaseType "MongoDB" -}}
        rezachalak/bzen-mongo:{{ .Chart.AppVersion }}
    {{- end -}}
{{- end -}}


{{/*
Create Uploader image address
*/}}
{{- define "backup-zen.cronjob.uploader.image" -}}
    {{- if .Values.cronjob.image -}}
        {{- .Values.cronjob.image -}}
    {{- else if eq .Values.backupUpload.objectStorageType "AWS_S3" -}}
        amazon/aws-cli:2.13.6
    {{- else if eq .Values.backupUpload.objectStorageType "MinIO" -}}
        minio/mc:RELEASE.2023-08-01T23-30-57Z.hotfix.09b6cd70
    {{- end -}}
{{- end -}}

{{/*
Create cronjob arg
*/}}
{{- define "backup-zen.cronjob.uploader.arg" -}}
    {{- if eq .Values.backupUpload.objectStorageType "AWS_S3" -}}
        {{- if .Values.global.teamsNotification -}}
            aws s3 sync --delete {{ template "backup-zen.backupDirectory" . }} s3://$(BUCKET_NAME)/{{template "backup-zen.name" . }}/ && curl -H 'Content-Type: application/json' -d '{"title": "{{.Values.databaseType}} Backups have been successfully synchronized with the Bucket.","text":"<pre>Pod name: $(KUBERNETES_POD_NAME)\nHost Address: $(DB_HOST)</pre>"}' $(SUCCEEDED_TEAMS_URL) || curl -H 'Content-Type: application/json' -d '{"title": "{{.Values.databaseType}} Backups failed to synchronize with the bucket.","text":"<pre>Pod name: $(KUBERNETES_POD_NAME)\nHost Address: $(DB_HOST)</pre>"}' $(FAILED_TEAMS_URL)
        {{- else -}}
            aws s3 sync --delete {{ template "backup-zen.backupDirectory" . }} s3://$(BUCKET_NAME)/{{template "backup-zen.name" . }}/
        {{- end -}}
    {{- else if eq .Values.backupUpload.objectStorageType "MinIO" -}}
        {{- if .Values.global.teamsNotification -}}
            mc alias set backupUploader $(MC_ENDPOINT) $(MC_ACCESS_KEY) $(MC_SECRET_KEY) && mc mirror --remove {{ template "backup-zen.backupDirectory" . }} backupUploader/$(OBJECT_NAME)/{{template "backup-zen.name" . }}/ && curl -H 'Content-Type: application/json' -d '{"title": "{{.Values.databaseType}} Backups have been successfully synchronized with the Bucket.","text":"<pre>Pod name: $(KUBERNETES_POD_NAME)\nHost Address: $(DB_HOST)</pre>"}' $(SUCCEEDED_TEAMS_URL) || curl -H 'Content-Type: application/json' -d '{"title": "{{.Values.databaseType}} Backups failed to synchronize with the bucket.","text":"<pre>Pod name: $(KUBERNETES_POD_NAME)\nHost Address: $(DB_HOST)</pre>"}' $(FAILED_TEAMS_URL)
        {{- else -}}
            mc alias set backupUploader $(MC_ENDPOINT) $(MC_ACCESS_KEY) $(MC_SECRET_KEY) && mc mirror --remove {{ template "backup-zen.backupDirectory" . }} backupUploader/$(OBJECT_NAME)/{{template "backup-zen.name" . }}/
        {{- end -}}
    {{- end -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "backup-zen.labels" -}}
app.kubernetes.io/name: backup-zen
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "backup-zen.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "backup-zen.selector" -}}
app.kubernetes.io/name: backup-zen
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create object storage name
*/}}
{{- define "backup-zen.objectStorageName" -}}
{{- if eq .Values.backupUpload.objectStorageType "AWS_S3" -}}
{{ include "backup-zen.name" . }}-s3-credentials
{{- end -}}
{{- if eq .Values.backupUpload.objectStorageType "MinIO" -}}
{{ include "backup-zen.name" . }}-minio-credentials
{{- end -}}
{{- end -}}

{{/*
Create pvc name
*/}}
{{- define "backup-zen.PVCName" -}}
{{- if .Values.cronjob.storage.createPVC -}}
    {{- if empty .Values.cronjob.storage.PVCName -}}
        {{ include "backup-zen.name" . }}-pvc
    {{- else -}}
        {{ .Values.cronjob.storage.PVCName }}
    {{- end -}}
{{- end -}}
{{- end -}}
