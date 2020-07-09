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
Calculate sternsoftadmin certificate
*/}}
{{- define "sternsoft.sternsoftadmin-certificate" }}
{{- if (not (empty .Values.ingress.sternsoftadmin.certificate)) }}
{{- printf .Values.ingress.sternsoftadmin.certificate }}
{{- else }}
{{- printf "%s-sternsoftadmin-letsencrypt" (include "sternsoft.fullname" .) }}
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
Calculate sternsoftadmin hostname
*/}}
{{- define "sternsoft.sternsoftadmin-hostname" }}
{{- if (and .Values.config.sternsoftadmin.hostname (not (empty .Values.config.sternsoftadmin.hostname))) }}
{{- printf .Values.config.sternsoftadmin.hostname }}
{{- else }}
{{- if .Values.ingress.sternsoftadmin.enabled }}
{{- printf .Values.ingress.sternsoftadmin.hostname }}
{{- else }}
{{- printf "%s-sternsoftadmin" (include "sternsoft.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate sternsoftadmin base url
*/}}
{{- define "sternsoft.sternsoftadmin-base-url" }}
{{- if (and .Values.config.sternsoftadmin.baseUrl (not (empty .Values.config.sternsoftadmin.baseUrl))) }}
{{- printf .Values.config.sternsoftadmin.baseUrl }}
{{- else }}
{{- if .Values.ingress.sternsoftadmin.enabled }}
{{- $hostname := ((empty (include "sternsoft.sternsoftadmin-hostname" .)) | ternary .Values.ingress.sternsoftadmin.hostname (include "sternsoft.sternsoftadmin-hostname" .)) }}
{{- $path := (eq .Values.ingress.sternsoftadmin.path "/" | ternary "" .Values.ingress.sternsoftadmin.path) }}
{{- $protocol := (.Values.ingress.sternsoftadmin.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "sternsoft.sternsoftadmin-hostname" .) }}
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
{{- $credentials := (empty $mongodb.username | ternary "" (printf "%s:%s" $mongodb.username $mongodb.password)) }}
{{- printf "mongodb://%s@%s:%s/%s" $credentials $mongodb.host $mongodb.port $mongodb.database }}
{{- end }}
{{- end }}
{{- end }}
