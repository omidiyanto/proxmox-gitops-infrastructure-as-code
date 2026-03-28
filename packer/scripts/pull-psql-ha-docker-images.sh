#!/bin/bash

IMAGES=(
    "bitnamilegacy/etcd:3.6.1"
    "haproxy:alpine"
    "ghcr.io/zalando/spilo-15:3.2-p1"
    "edoburu/pgbouncer:latest"
    "rustfs/rustfs:latest"
    "minio/mc"
    "alpine"
)

echo "Starting Docker image pull process..."
echo "-------------------------------------"

for IMAGE in "${IMAGES[@]}"; do
    echo "Pulling: $IMAGE"
    sudo docker pull "$IMAGE"
    
    if [ $? -eq 0 ]; then
        echo "Success: $IMAGE"
    else
        echo "Failed: $IMAGE"
    fi
    echo "-------------------------------------"
done

echo "All pulls completed."