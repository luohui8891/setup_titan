#!/bin/bash

read -p "你的用户码: " user_hash
read -p "每个容器存储空间（GB）: " storage_gb

# 指定要搜索的镜像名称
image_name="nezha123/titan-edge"

echo "检查Docker......"
docker -v
# 检查 Docker 是否已经安装
if [ $? -eq  0 ];then
    echo "docker已安装！"
else
    # 尝试识别操作系统
    if [ -f /etc/os-release ]; then
        # 加载操作系统信息
        . /etc/os-release
        
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
            # 使用 apt 安装 Docker
            sudo apt-get update
            sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
            curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable"
            sudo apt-get update
            sudo apt-get install docker-ce docker-ce-cli containerd.io
            sudo systemctl start docker
        elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
            # 使用 yum 安装 Docker
            sudo yum install -y yum-utils device-mapper-persistent-data lvm2
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl start docker
        else
            echo "抱歉该脚本暂不支持你的操作系统版本，请手动安装docker."
            exit 1
        fi
    else
        echo "抱歉没识别到你的操作系统呢，请手动安装docker."
        exit 1
    fi
    systemctl enable  docker
fi

# 启动 Docker 服务
systemctl start docker

# 拉取镜像
echo "Pulling Docker image: $image_name"
docker pull "$image_name"

# 检查镜像是否拉取成功
if [ $? -ne 0 ]; then
  echo "Failed to pull Docker image: $image_name"
  exit 1
fi

docker compose up -d
sleep 10


# 設置 Docker 容器 50G
storage_command="titan-edge config set --storage-size "$storage_gb"GB"
# 绑定 hash
bind_command="titan-edge bind --hash="$user_hash" https://api-test1.container1.titannet.io/api/v2/device/binding"

for i in {1..5}; do
    docker exec -it titan$i bash -c "$storage_command"
    docker exec -it titan$i bash -c "$bind_command"
done

docker compose restart