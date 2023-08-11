{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pg-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pg-backup.fullname" -}}
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
{{- define "pg-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create filename
*/}}
{{- define "pg-backup.filename" -}}
{{- if .Values.filename -}}
{{- .Values.filename -}}
{{- else -}}
{{- .Values.database.name -}}
{{- end -}}
{{- end -}}

{{/*
Create namespace name
*/}}
{{- define "pg-backup.namespace" -}}
    {{- if .Values.global.namespace -}}
        {{- .Values.global.namespace -}}
    {{- else if .Values.global.createNamespace -}}
        {{- fail "namespace is missing in values file" -}}
    {{- else -}}
        default
    {{- end -}}
{{- end -}}

{{/*
Create image address
*/}}
{{- define "pg-backup.cronjob.image" -}}
    {{- if .Values.cronjob.image -}}
        {{- .Values.cronjob.image -}}
    {{- else -}}
        avidcloud/pg-backup-zen:latest
    {{- end -}}
{{- end -}}


{{/*
Create cronjob arg
*/}}
{{- define "pg-backup.cronjob.uploader.arg" -}}
    {{- if eq .Values.backupUpload.ObjectStorageType "AWS_S3" -}}
        {{- if .Values.global.teamsNotification -}}
                aws s3 sync --delete /backups s3://$(BUCKET_NAME)/postgres-rds/ && curl -H 'Content-Type: application/json' -d '{"title": "PostgreSQL backups successfully synced with S3 Bucket","text":"Pod name: $(KUBERNETES_POD_NAME)"}' $(SUCCEEDED_TEAMS_URL) || curl -H 'Content-Type: application/json' -d '{"title": "PostgreSQL backups failed to be synced with S3 Bucket","text":"Job name: $(KUBERNETES_POD_NAME)"}' $(FAILED_TEAMS_URL)
        {{- else -}}
                aws s3 sync --delete /backups s3://$(BUCKET_NAME)/postgres-rds/
        {{- end -}}
    {{- else if eq .Values.backupUpload.ObjectStorageType "MinIO" -}}
        {{- if .Values.global.teamsNotification -}}
                mc s3 sync --delete /backups s3://$(BUCKET_NAME)/postgres-rds/ && curl -H 'Content-Type: application/json' -d '{"title": "PostgreSQL backups successfully synced with S3 Bucket","text":"Pod name: $(KUBERNETES_POD_NAME)"}' $(SUCCEEDED_TEAMS_URL) || curl -H 'Content-Type: application/json' -d '{"title": "PostgreSQL backups failed to be synced with S3 Bucket","text":"Job name: $(KUBERNETES_POD_NAME)"}' $(FAILED_TEAMS_URL)
        {{- else -}}
                mc sync --delete /backups s3://$(BUCKET_NAME)/postgres-rds/
        {{- end -}}
    {{- end -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "pg-backup.labels" -}}
app.kubernetes.io/name: pg-backup
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "pg-backup.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "pg-backup.selector" -}}
app.kubernetes.io/name: pg-backup
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create object storage name
*/}}
{{- define "pg-backup.objectStorageName" -}}
{{- if eq .Values.backupUpload.ObjectStorageType "AWS_S3" -}}
{{ include "pg-backup.name" . }}-s3-credentials
{{- end -}}
{{- if eq .Values.backupUpload.ObjectStorageType "MinIO" -}}
{{ include "pg-backup.name" . }}-minio-credentials
{{- end -}}
{{- end -}}

{{/*
Create pvc name
*/}}
{{- define "pg-backup.PVCName" -}}
{{- if .Values.cronjob.storage.createPVC -}}
    {{- if empty .Values.cronjob.storage.PVCName -}}
        {{ include "pg-backup.name" . }}-pvc
    {{- else -}}
        {{ .Values.cronjob.storage.PVCName }}
    {{- end -}}
{{- end -}}
{{- end -}}
