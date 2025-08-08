#!/bin/bash

set -e

RELEASE_NAME="bytebase-release"
NAMESPACE="bytebase"

helm repo add bytebase https://bytebase.github.io/bytebase
helm repo update

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

if helm status $RELEASE_NAME -n $NAMESPACE > /dev/null 2>&1; then
  echo "Upgrade Bytebase tanpa mengubah storageClass"
  helm upgrade $RELEASE_NAME bytebase/bytebase \
    --namespace $NAMESPACE \
    --set "bytebase.option.port"=443 \
    --set "bytebase.option.externalPg.url"="postgresql://bytebase:bytebase@bytebase-db-postgresql.bytebase.svc.cluster.local:5432/bytebase" \
    --set "bytebase.option.external-url"="https://bytebase.ngrok-free.app" \
    --set "bytebase.persistence.enabled"="true" \
    --set "bytebase.persistence.storage"="10Gi"
else
  echo "Install Bytebase baru dengan storageClass kosong"
  helm install $RELEASE_NAME bytebase/bytebase \
    --namespace $NAMESPACE --create-namespace \
    --set "bytebase.option.port"=443 \
    --set "bytebase.option.externalPg.url"="postgresql://bytebase:bytebase@bytebase-db-postgresql.bytebase.svc.cluster.local:5432/bytebase" \
    --set "bytebase.option.external-url"="https://bytebase.ngrok-free.app" \
    --set "bytebase.persistence.enabled"="true" \
    --set "bytebase.persistence.storage"="10Gi" \
    --set "bytebase.persistence.storageClass"="local-path"
fi

kubectl wait --for=condition=available --timeout=90s deployment/$RELEASE_NAME -n $NAMESPACE || true
sleep 5

kubectl patch svc bytebase-entrypoint -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}' || true

echo "=== STATUS PVC ==="
kubectl get pvc -n $NAMESPACE

# Cek apakah ada PVC yang Pending
PVC_PENDING=$(kubectl get pvc -n $NAMESPACE --no-headers | grep Pending || true)
if [[ -n "$PVC_PENDING" ]]; then
  echo "❌ ERROR: Ada PVC dengan status Pending. Pastikan PersistentVolume tersedia dan StorageClass benar."
  exit 1
fi

echo "=== STATUS POD ==="
kubectl get pod -n $NAMESPACE

# Cek apakah ada Pod yang Pending
POD_PENDING=$(kubectl get pod -n $NAMESPACE --no-headers | grep Pending || true)
if [[ -n "$POD_PENDING" ]]; then
  echo "❌ ERROR: Ada Pod dengan status Pending. Periksa event pod untuk detail lebih lanjut."
  exit 1
fi

echo "=== STATUS SERVICE ==="
kubectl get svc -n $NAMESPACE

echo "🤩 Install/upgrade Bytebase selesai."
