# scs

Umbrella chart, cài toàn bộ component của k8s-homelab-template-system bằng một lệnh `helm`.

| Component | Chart | Bật/tắt |
| --- | --- | --- |
| PostgreSQL | [`components/postgres-db`](../components/postgres-db) | `postgres-db.enabled` |

Các component được tham chiếu bằng đường dẫn `file://../components/...`, nên phải chạy chart này từ trong repo `root` (clone kèm `--recurse-submodules`).

## Yêu cầu

Cài operator CloudNativePG một lần cho cả cluster:

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg cnpg/cloudnative-pg --version 0.29.1 \
  --namespace cnpg-system --create-namespace
```

Operator được cài riêng, không đưa vào umbrella chart, vì CRD `Cluster` phải có trước khi Helm tạo resource `Cluster`.

## Cài đặt

Chạy từ thư mục `root`:

```bash
helm dependency build components/postgres-db
helm dependency build scs
helm upgrade --install scs scs --namespace homelab --create-namespace
```

Ghi đè cấu hình trong [values.yaml](values.yaml) theo dạng `<component>.<key>`, ví dụ:

```yaml
postgres-db:
  cluster:
    cluster:
      instances: 3
```
