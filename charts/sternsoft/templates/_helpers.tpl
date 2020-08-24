{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sternsoft.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "sternsoft.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate admin frontend certificate
*/}}
{{- define "sternsoft.admin-fe-certificate" }}
{{- if (not (empty .Values.ingress.adminFE.certificate)) }}
{{- printf .Values.ingress.adminFE.certificate }}
{{- else }}
{{- printf "%s-adminFE-letsencrypt" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate admin api certificate
*/}}
{{- define "sternsoft.admin-api-certificate" }}
{{- if (not (empty .Values.ingress.adminApi.certificate)) }}
{{- printf .Values.ingress.adminApi.certificate }}
{{- else }}
{{- printf "%s-adminApi-letsencrypt" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate mongo express certificate
*/}}
{{- define "sternsoft.mongo-express-certificate" }}
{{- if (not (empty .Values.ingress.mongoExpress.certificate)) }}
{{- printf .Values.ingress.mongoExpress.certificate }}
{{- else }}
{{- printf "%s-mongo-express-letsencrypt" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate admin hostname
*/}}
{{- define "sternsoft.admin-fe-hostname" }}
{{- if (and .Values.config.adminFE.hostname (not (empty .Values.config.adminFE.hostname))) }}
{{- printf .Values.config.adminFE.hostname }}
{{- else }}
{{- if .Values.ingress.adminFE.enabled }}
{{- printf .Values.ingress.adminFE.hostname }}
{{- else }}
{{- printf "%s-adminFE" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate admin frontend base url
*/}}
{{- define "sternsoft.admin-fe-base-url" }}
{{- if (and .Values.config.adminFE.baseUrl (not (empty .Values.config.adminFE.baseUrl))) }}
{{- printf .Values.config.adminFE.baseUrl }}
{{- else }}
{{- if .Values.ingress.adminFE.enabled }}
{{- $hostname := ((empty (include "sternsoft.admin-fe-hostname" .)) | ternary .Values.ingress.adminFE.hostname (include "sternsoft.admin-fe-hostname" .)) }}
{{- $protocol := (.Values.ingress.adminFE.tls | ternary "https" "http") }}
{{- printf "%s://%s" $protocol $hostname }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.admin-fe-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate admin api hostname
*/}}
{{- define "sternsoft.admin-api-hostname" }}
{{- if (and .Values.config.adminApi.hostname (not (empty .Values.config.adminApi.hostname))) }}
{{- printf .Values.config.adminApi.hostname }}
{{- else }}
{{- if .Values.ingress.adminApi.enabled }}
{{- printf .Values.ingress.adminApi.hostname }}
{{- else }}
{{- printf "%s-adminApi" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate admin api base url
*/}}
{{- define "sternsoft.admin-api-base-url" }}
{{- if (and .Values.config.adminApi.baseUrl (not (empty .Values.config.adminApi.baseUrl))) }}
{{- printf .Values.config.adminApi.baseUrl }}
{{- else }}
{{- if .Values.ingress.adminApi.enabled }}
{{- $hostname := ((empty (include "sternsoft.admin-api-hostname" .)) | ternary .Values.ingress.adminApi.hostname (include "sternsoft.admin-api-hostname" .)) }}
{{- $protocol := (.Values.ingress.adminApi.tls | ternary "https" "http") }}
{{- printf "%s://%s" $protocol $hostname }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.adminApi-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate mongodb server
*/}}
{{- define "sternsoft.mongodb-server" }}
{{- if .Values.config.mongodb.replicaSet.enabled }}
{{- printf "%s-mongodb-0.%s-mongodb-gvr.%s.svc,%s-mongodb-1.%s-mongodb-gvr.%s.svc,%s-mongodb-2.%s-mongodb-gvr.%s.svc" (include "sternsoft.fullname" .) (include "sternsoft.fullname" .) .Release.Namespace (include "sternsoft.fullname" .) (include "sternsoft.fullname" .) .Release.Namespace (include "sternsoft.fullname" .) (include "sternsoft.fullname" .) .Release.Namespace }}
{{- else }}
{{- printf "%s-mongodb" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate mongodb url
*/}}
{{- define "sternsoft.mongodb-url" }}
{{- $mongodb := .Values.config.mongodb }}
{{- if $mongodb.internal }}
{{- printf "mongodb://%s-mongodb:27017/%s" (include "sternsoft.fullname" .) $mongodb.database }}
{{- else }}
{{- if $mongodb.url }}
{{- printf $mongodb.url }}
{{- else }}
{{- $credentials := (empty $mongodb.username | ternary "" (printf "%s:%s@" $mongodb.username $mongodb.password)) }}
{{- printf "mongodb://%s%s:%s/%s" $credentials $mongodb.host $mongodb.port $mongodb.database }}
{{- end }}
{{- end }}
{{- end }}
