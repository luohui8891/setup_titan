#!/bin/bash

read -p "请输入你想要分配每: " storage_gb
# 設置 Docker 容器 50G
storage_command="titan-edge config set --storage-size "$storage_gb"GB"

# 循環進入每個容器，並執行命令
for i in {1..5}; do
    docker exec -it titan$i bash -c "$storage_command"
done

docker compose restart