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
Calculate admin certificate
*/}}
{{- define "sternsoft.admin-certificate" }}
{{- if (not (empty .Values.ingress.admin.certificate)) }}
{{- printf .Values.ingress.admin.certificate }}
{{- else }}
{{- printf "%s-admin-letsencrypt" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate api certificate
*/}}
{{- define "sternsoft.api-certificate" }}
{{- if (not (empty .Values.ingress.api.certificate)) }}
{{- printf .Values.ingress.api.certificate }}
{{- else }}
{{- printf "%s-api-letsencrypt" (include "sternsoft.fullname" .) }}
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
{{- define "sternsoft.admin-hostname" }}
{{- if (and .Values.config.admin.hostname (not (empty .Values.config.admin.hostname))) }}
{{- printf .Values.config.admin.hostname }}
{{- else }}
{{- if .Values.ingress.admin.enabled }}
{{- printf .Values.ingress.admin.hostname }}
{{- else }}
{{- printf "%s-admin" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate admin base url
*/}}
{{- define "sternsoft.admin-base-url" }}
{{- if (and .Values.config.admin.baseUrl (not (empty .Values.config.admin.baseUrl))) }}
{{- printf .Values.config.admin.baseUrl }}
{{- else }}
{{- if .Values.ingress.admin.enabled }}
{{- $hostname := ((empty (include "sternsoft.admin-hostname" .)) | ternary .Values.ingress.admin.hostname (include "sternsoft.admin-hostname" .)) }}
{{- $protocol := (.Values.ingress.admin.tls | ternary "https" "http") }}
{{- printf "%s://%s" $protocol $hostname }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.admin-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate api hostname
*/}}
{{- define "sternsoft.api-hostname" }}
{{- if (and .Values.config.api.hostname (not (empty .Values.config.api.hostname))) }}
{{- printf .Values.config.api.hostname }}
{{- else }}
{{- if .Values.ingress.api.enabled }}
{{- printf .Values.ingress.api.hostname }}
{{- else }}
{{- printf "%s-api" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate api base url
*/}}
{{- define "sternsoft.api-base-url" }}
{{- if (and .Values.config.api.baseUrl (not (empty .Values.config.api.baseUrl))) }}
{{- printf .Values.config.api.baseUrl }}
{{- else }}
{{- if .Values.ingress.api.enabled }}
{{- $hostname := ((empty (include "sternsoft.api-hostname" .)) | ternary .Values.ingress.api.hostname (include "sternsoft.api-hostname" .)) }}
{{- $protocol := (.Values.ingress.api.tls | ternary "https" "http") }}
{{- printf "%s://%s" $protocol $hostname }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.api-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate tools api hostname
*/}}
{{- define "sternsoft.toolsApi-hostname" }}
{{- if (and .Values.config.toolsApi.hostname (not (empty .Values.config.toolsApi.hostname))) }}
{{- printf .Values.config.toolsApi.hostname }}
{{- else }}
{{- if .Values.ingress.toolsApi.enabled }}
{{- printf .Values.ingress.toolsApi.hostname }}
{{- else }}
{{- printf "%s-toolsApi" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate tools api base url
*/}}
{{- define "sternsoft.toolsApi-base-url" }}
{{- if (and .Values.config.toolsApi.baseUrl (not (empty .Values.config.toolsApi.baseUrl))) }}
{{- printf .Values.config.toolsApi.baseUrl }}
{{- else }}
{{- if .Values.ingress.toolsApi.enabled }}
{{- $hostname := ((empty (include "sternsoft.toolsApi-hostname" .)) | ternary .Values.ingress.toolsApi.hostname (include "sternsoft.api-hostname" .)) }}
{{- $protocol := (.Values.ingress.toolsApi.tls | ternary "https" "http") }}
{{- printf "%s://%s" $protocol $hostname }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.toolsApi-hostname" .) }}
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
