{{/*
Giá trị (đã giải mã) của một key trong Secret infisical-secrets đang có trong cluster.
Trả về "" khi cài lần đầu. Dùng chung cho templates/secret.yaml và mật khẩu truyền cho
chart bitnami/postgresql, bitnami/redis trong values.yaml.
Params: key, context
*/}}
{{- define "homelab.infisical.storedCredential" -}}
{{- $data := (lookup "v1" "Secret" .context.Release.Namespace "infisical-secrets").data | default dict -}}
{{- index $data .key | default "" | b64dec -}}
{{- end -}}
