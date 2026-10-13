# scs

Umbrella chart, cài toàn bộ component của k8s-homelab-template-system bằng một lệnh `helm`.

| Component | Chart | Bật/tắt |
| --- | --- | --- |
| PostgreSQL | [`components/postgres-db`](../components/postgres-db) (wrap `bitnami/postgresql`) | `postgres-db.enabled` |

Các component được tham chiếu bằng đường dẫn `file://../components/...`, nên phải chạy chart này từ trong repo `root` (clone kèm `--recurse-submodules`).

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
  postgresql:
    primary:
      persistence:
        size: 20Gi
```
