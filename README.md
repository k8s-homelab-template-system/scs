# scs

Umbrella chart gom các component của k8s-homelab-template-system, deploy bằng Rancher Fleet.

| Component | Chart | Bật/tắt |
| --- | --- | --- |
| PostgreSQL | `oci://ghcr.io/k8s-homelab-template-system/charts/postgres-db` (wrap `bitnami/postgresql`) | `postgres-db.enabled` |
| MongoDB | `oci://ghcr.io/k8s-homelab-template-system/charts/mongo-db` (wrap `bitnami/mongodb`) | `mongo-db.enabled` |
| RabbitMQ | `oci://ghcr.io/k8s-homelab-template-system/charts/rabbitmq` (wrap `bitnami/rabbitmq`) | `rabbitmq.enabled` |

Ghi đè cấu hình trong [values.yaml](values.yaml) theo dạng `<component>.<key>`.

`global.baseDomain` (hiện là `vodka.bid`) là domain gốc dùng chung: mỗi component chỉ khai báo `ingress.subdomain`, host thành `<subdomain>.<baseDomain>`. Chart con chỉ đọc được `global.*` của chart cha, nên biến này phải nằm trong `global`.

| Host | Component | Trỏ tới |
| --- | --- | --- |
| `rabbitmq-mgm.vodka.bid` | rabbitmq | management UI (port 15672) |

## Public qua Cloudflare Tunnel

Cluster đã có sẵn [Cloudflare Tunnel Ingress Controller](https://github.com/STRRL/cloudflare-tunnel-ingress-controller) 0.1.0 (cài bằng Helm tay, namespace `cloudflare-tunnel-ingress-controller`, credential trong Secret `cloudflare-api`), dùng một tunnel `k3s-home` cho mọi subdomain, kể cả `rancher.vodka.bid`.

Mỗi Ingress có `ingressClassName: cloudflare-tunnel` được controller tự thêm route vào tunnel và tự tạo DNS CNAME, không cần khai báo gì trên Cloudflare. Traffic đi thẳng từ tunnel vào Service, Cloudflare lo TLS (Universal SSL chỉ phủ 1 cấp subdomain).

Controller ghi đè toàn bộ route của tunnel bằng các Ingress trong cluster: hostname thêm tay trên Cloudflare dashboard sẽ bị xóa, hãy khai báo bằng Ingress.

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
