### Database
``` bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

``` bash
helm install bytebase-db bitnami/postgresql \
  --namespace bytebase --create-namespace \
  --set auth.username=bytebase \
  --set auth.password=bytebase \
  --set auth.database=bytebase \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi
```
