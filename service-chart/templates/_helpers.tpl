{{/*
Expand the name of the chart.
*/}}
{{- define "service-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "service-chart.fullname" -}}
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
{{- define "service-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "service-chart.labels" -}}
helm.sh/chart: {{ include "service-chart.chart" . }}
{{ include "service-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "service-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "service-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "service-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "pvc.lookup" -}}
{{- if .Values.pvc.create }}
{{- if not .Values.pvc.name -}}
{{- fail "A valid .Values.pvc.name entry required!" -}}
{{- end -}}
{{- if not (lookup "v1" "PersistentVolumeClaim" .Release.Namespace .Values.pvc.name ) }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.pvc.name }}
  annotations:
  {{- toYaml .Values.pvc.annotations | nindent 4 }}
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: {{ required "A valid .Values.pvc.storageClass entry required!" .Values.pvc.storageClass }}
  resources:
    requests:
      storage: {{ required "A valid .Values.pvc.storageSize entry required!" .Values.pvc.storageSize }}
{{- end -}}
{{- end -}}
{{- end -}}