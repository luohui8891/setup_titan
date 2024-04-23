#!/bin/bash

read -p "请输入你想要分配每个节点存储（GB）: " storage_gb
# 設置 Docker 容器 50G
storage_command="titan-edge config set --storage-size "$storage_gb"GB"

for i in {1..5}; do
    docker exec -it titan1 bash -c "$storage_command"
done

docker compose restart