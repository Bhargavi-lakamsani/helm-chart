{{- define "nginx-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nginx-chart.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "nginx-chart.labels" -}}
app.kubernetes.io/name: {{ include "nginx-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

