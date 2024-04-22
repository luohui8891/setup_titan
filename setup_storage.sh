#!/bin/bash

read -p "请输入你想要分配每个节点存储（GB）: " storage_gb
# 設置 Docker 容器 50G
storage_command="titan-edge config set --storage-size "$storage_gb"GB"

# 现在只有一个节点了
docker exec -it titan1 bash -c "$storage_command"

docker compose restart