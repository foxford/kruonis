{{/*
Expand the name of the chart.
*/}}
{{- define "kruonis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Service name.
*/}}
{{- define "kruonis.serviceName" -}}
{{- list (default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-") "service" | join "-" }}
{{- end }}

{{/*
Short namespace.
*/}}
{{- define "kruonis.shortNamespace" -}}
{{- $shortns := regexSplit "-" .Release.Namespace -1 | first }}
{{- if has $shortns (list "production" "p") }}
{{- else }}
{{- $shortns }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kruonis.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kruonis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kruonis.labels" -}}
helm.sh/chart: {{ include "kruonis.chart" . }}
app.kubernetes.io/name: {{ include "kruonis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
k8s-app: {{ include "kruonis.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kruonis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kruonis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "kruonis.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kruonis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kruonis.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create volumeMount name
*/}}
{{- define "kruonis.volumeMountName" -}}
{{- $prefix := index . 0 -}}
{{- $secret := index . 1 -}}
{{- printf "%s-%s-secret" $prefix $secret | replace "." "-" | trunc 63 }}
{{- end }}
