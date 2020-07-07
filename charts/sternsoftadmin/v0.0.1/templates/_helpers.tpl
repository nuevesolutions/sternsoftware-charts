{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sternsoftadmin.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "sternsoftadmin.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a name shared accross all apps in namespace.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "sternsoftadmin.sharedname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Namespace $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate sternsoftadmin certificate
*/}}
{{- define "sternsoftadmin.sternsoftadmin-certificate" }}
{{- if (not (empty .Values.ingress.sternsoftadmin.certificate)) }}
{{- printf .Values.ingress.sternsoftadmin.certificate }}
{{- else }}
{{- printf "%s-sternsoftadmin-letsencrypt" (include "sternsoftadmin.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate sternsoftadmin hostname
*/}}
{{- define "sternsoftadmin.sternsoftadmin-hostname" }}
{{- if (and .Values.config.sternsoftadmin.hostname (not (empty .Values.config.sternsoftadmin.hostname))) }}
{{- printf .Values.config.sternsoftadmin.hostname }}
{{- else }}
{{- if .Values.ingress.sternsoftadmin.enabled }}
{{- printf .Values.ingress.sternsoftadmin.hostname }}
{{- else }}
{{- printf "%s-sternsoftadmin" (include "sternsoftadmin.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate sternsoftadmin base url
*/}}
{{- define "sternsoftadmin.sternsoftadmin-base-url" }}
{{- if (and .Values.config.sternsoftadmin.baseUrl (not (empty .Values.config.sternsoftadmin.baseUrl))) }}
{{- printf .Values.config.sternsoftadmin.baseUrl }}
{{- else }}
{{- if .Values.ingress.sternsoftadmin.enabled }}
{{- $hostname := ((empty (include "sternsoftadmin.sternsoftadmin-hostname" .)) | ternary .Values.ingress.sternsoftadmin.hostname (include "sternsoftadmin.sternsoftadmin-hostname" .)) }}
{{- $path := (eq .Values.ingress.sternsoftadmin.path "/" | ternary "" .Values.ingress.sternsoftadmin.path) }}
{{- $protocol := (.Values.ingress.sternsoftadmin.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "sternsoftadmin.sternsoftadmin-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}
