{{- define "volumes" }}
- name: config
  configMap:
    name: {{ .Chart.Name }}-config
- name: tls
  secret:
    secretName: tls-certificates
- name: svc
  secret:
    secretName: svc-pem-credentials
{{- range $tenant := .Values.app.tenants }}
- name: {{ $tenant.name | lower }}
  secret:
    secretName: secrets-{{ $tenant.name | lower }}
{{- end }}
{{- end }}

{{- define "volumeMounts" }}
- name: config
  mountPath: /app/App.toml
  subPath: App.toml
- name: tls
  mountPath: /tls
- name: svc
  mountPath: /app/data/keys/svc.public_key.pem
  subPath: svc.public_key
{{- range $tenant := .Values.app.tenants }}
- name: {{ $tenant.name | lower }}
  mountPath: {{ printf "/app/data/keys/%s.pem" (pluck $.Values.werf.env $tenant.authn.key | first | default $tenant.authn.key._default) }}
  subPath: {{ pluck $.Values.werf.env $tenant.authn.key | first | default $tenant.authn.key._default }}
{{- end }}
{{- end }}