# scs

Cài các component của k8s-homelab-template-system bằng Rancher Fleet. Mỗi thư mục là một bundle, Fleet kéo chart trực tiếp từ `ghcr.io` (package private).

| Component | Chart | Cấu hình |
| --- | --- | --- |
| PostgreSQL | `oci://ghcr.io/k8s-homelab-template-system/charts/postgres-db` (wrap `bitnami/postgresql`) | [postgres-db/fleet.yaml](postgres-db/fleet.yaml) |

Thêm component mới: tạo thư mục `<component>/fleet.yaml` với `helm.chart` trỏ tới `oci://ghcr.io/k8s-homelab-template-system/charts/<component>`.

## Xác thực ghcr.io

Tạo Secret chứa PAT có scope `read:packages` trong namespace của GitRepo:

```bash
read -s GHCR_PAT
kubectl -n fleet-default create secret generic ghcr-helm-auth \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=<github-user> \
  --from-literal=password="$GHCR_PAT"
```

GitRepo:

```yaml
spec:
  repo: https://github.com/k8s-homelab-template-system/scs.git
  branch: main
  helmSecretName: ghcr-helm-auth
  helmRepoURLRegex: ghcr.io/k8s-homelab-template-system/.*
```

Không dùng umbrella chart (`dependencies:` trong `Chart.yaml`): Fleet không truyền `helmSecretName` cho bước `helm dependency update`, nên chart con private sẽ lỗi 401.

## Cài thủ công bằng helm

```bash
helm registry login ghcr.io -u <github-user>
helm upgrade --install postgres-db oci://ghcr.io/k8s-homelab-template-system/charts/postgres-db \
  --version 0.2.0 --namespace homelab --create-namespace
```
