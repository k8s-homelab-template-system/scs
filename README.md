# scs

Umbrella chart gom các component của k8s-homelab-template-system, deploy bằng Rancher Fleet.

| Component | Chart | Bật/tắt |
| --- | --- | --- |
| PostgreSQL | `oci://ghcr.io/k8s-homelab-template-system/charts/postgres-db` (wrap `bitnami/postgresql`) | `postgres-db.enabled` |

Ghi đè cấu hình trong [values.yaml](values.yaml) theo dạng `<component>.<key>`.

`global.baseDomain` (hiện là `vodka.bid`) là domain gốc dùng chung: mỗi component chỉ khai báo `ingress.subdomain`, host thành `<subdomain>.<baseDomain>`. Chart con chỉ đọc được `global.*` của chart cha, nên biến này phải nằm trong `global`.

| Host | Component | Trỏ tới |
| --- | --- | --- |
| `rabbitmq-mgm.vodka.bid` | rabbitmq | management UI (port 15672) |

Cloudflare Tunnel dùng wildcard nên thêm component không cần khai báo gì trên Cloudflare, chỉ cần Ingress có host `<subdomain>.vodka.bid`:

- Tunnel → Public Hostname: `*.vodka.bid` → `HTTP` → ingress controller của cluster (port 80)
- DNS: CNAME `*` → `<tunnel-id>.cfargotunnel.com` (proxied)

Cloudflare lo TLS (Universal SSL phủ `*.vodka.bid`, chỉ 1 cấp subdomain), Ingress chỉ cần HTTP. Host không khớp Ingress nào sẽ nhận 404 từ ingress controller.

## Luồng CD

1. Push `components/<name>` → workflow `helm-release` publish chart lên ghcr.io (private) và sửa `version` của dependency trong [Chart.yaml](Chart.yaml).
2. Push `Chart.yaml` → workflow [vendor-charts](.github/workflows/vendor-charts.yaml) chạy `helm dependency update` và commit `Chart.lock` + `charts/*.tgz`.
3. Fleet deploy chart ở thư mục gốc với `helm.disableDependencyUpdate: true` ([fleet.yaml](fleet.yaml)), dùng `charts/*.tgz` đã commit nên không cần đăng nhập ghcr.io.

Không để Fleet tự tải dependency: Fleet không dùng `helmSecretName` cho bước `helm dependency update`, chart private sẽ lỗi 401.

## Thêm component

1. Publish chart từ `components/<name>`.
2. Package `charts/<name>` → Package settings → Manage Actions access → thêm repo `scs` với role **Read**.
3. Thêm vào `dependencies` trong `Chart.yaml` và `<name>.enabled` trong `values.yaml`, rồi push.

## Cài thủ công bằng helm

```bash
helm registry login ghcr.io -u <github-user>
helm dependency update scs
helm upgrade --install scs scs --namespace homelab --create-namespace
```
