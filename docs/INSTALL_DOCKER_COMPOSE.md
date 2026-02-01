# 🔧 Docker Compose 安装指南

## 问题：bash: docker-compose: command not found

这个错误表示系统中没有安装 `docker-compose` 命令。

## 📋 两个版本说明

### Docker Compose V1（旧版）
- 命令：`docker-compose`（带连字符）
- 独立的二进制文件
- 正在被V2取代

### Docker Compose V2（新版）⭐
- 命令：`docker compose`（空格，不是连字符）
- 作为Docker插件集成
- 推荐使用

## ✅ 解决方案

### 方案1：使用Docker Compose V2（推荐）

#### 1.1 检查是否已安装

```bash
docker compose version
```

如果显示版本号（如：`Docker Compose version v2.x.x`），说明已安装，直接使用即可。

#### 1.2 使用V2命令

```bash
# 替换所有 docker-compose 为 docker compose（注意是空格）
docker compose up -d --build
docker compose down
docker compose ps
docker compose logs -f web
docker compose exec web bash
```

#### 1.3 如果未安装V2

**Ubuntu/Debian**:
```bash
# 更新Docker到最新版本
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 验证安装
docker compose version
```

**CentOS/RHEL**:
```bash
sudo yum update
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 验证安装
docker compose version
```

---

### 方案2：安装Docker Compose V1

如果您需要使用 `docker-compose` 命令（带连字符）：

#### 2.1 下载安装（Linux）

```bash
# 下载最新版本（替换为最新版本号）
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 创建软链接（可选，但推荐）
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 验证安装
docker-compose --version
```

#### 2.2 使用包管理器安装

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install docker-compose
```

**CentOS/RHEL**:
```bash
sudo yum install docker-compose
```

**使用pip安装**:
```bash
sudo pip install docker-compose
```

---

### 方案3：创建别名（快速方案）

如果Docker Compose V2已安装，但想继续使用 `docker-compose` 命令：

```bash
# 临时别名（当前会话有效）
alias docker-compose='docker compose'

# 永久别名（添加到 ~/.bashrc 或 ~/.zshrc）
echo "alias docker-compose='docker compose'" >> ~/.bashrc
source ~/.bashrc

# 验证
docker-compose version
```

---

## 🚀 快速部署命令对照表

| 操作 | V1 命令 | V2 命令 |
|------|---------|---------|
| 启动 | `docker-compose up -d` | `docker compose up -d` |
| 停止 | `docker-compose stop` | `docker compose stop` |
| 重启 | `docker-compose restart` | `docker compose restart` |
| 查看状态 | `docker-compose ps` | `docker compose ps` |
| 查看日志 | `docker-compose logs -f` | `docker compose logs -f` |
| 进入容器 | `docker-compose exec web bash` | `docker compose exec web bash` |
| 停止并删除 | `docker-compose down` | `docker compose down` |
| 构建并启动 | `docker-compose up -d --build` | `docker compose up -d --build` |

---

## 🔍 检查当前环境

### 1. 检查Docker版本
```bash
docker --version
# 输出示例: Docker version 24.0.7, build afdd53b
```

### 2. 检查Docker Compose版本
```bash
# 尝试V2
docker compose version
# 输出示例: Docker Compose version v2.24.0

# 尝试V1
docker-compose --version
# 输出示例: docker-compose version 1.29.2
```

### 3. 检查Docker服务状态
```bash
sudo systemctl status docker
```

---

## 📝 推荐配置（生产环境）

### 1. 安装最新版Docker和Compose V2

**Ubuntu 22.04/20.04**:
```bash
# 卸载旧版本
sudo apt-get remove docker docker-engine docker.io containerd runc

# 安装依赖
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 设置仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine和Compose插件
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 验证安装
docker --version
docker compose version
```

**CentOS 7/8**:
```bash
# 卸载旧版本
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest

# 安装依赖
sudo yum install -y yum-utils

# 添加Docker仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker和Compose插件
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
docker --version
docker compose version
```

### 2. 配置非root用户运行Docker

```bash
# 创建docker组
sudo groupadd docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录或运行
newgrp docker

# 验证（无需sudo）
docker ps
```

---

## 🎯 快速解决流程

### 步骤1：检查Docker Compose V2
```bash
docker compose version
```

**如果有输出** → 使用方案1（推荐）  
**如果没有输出** → 继续步骤2

### 步骤2：安装Docker Compose

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

**CentOS/RHEL**:
```bash
sudo yum install docker-compose-plugin
```

### 步骤3：验证并部署
```bash
# 验证
docker compose version

# 部署项目
cd /path/to/wps_open_api
docker compose up -d --build
```

---

## 🐛 常见问题

### 问题1：权限被拒绝
```bash
# 错误：Got permission denied while trying to connect to the Docker daemon socket
```

**解决**：
```bash
# 方案A：使用sudo
sudo docker compose up -d

# 方案B：添加用户到docker组（推荐）
sudo usermod -aG docker $USER
newgrp docker
```

### 问题2：端口被占用
```bash
# 错误：Bind for 0.0.0.0:8080 failed: port is already allocated
```

**解决**：
```bash
# 查看端口占用
sudo lsof -i :8080

# 修改端口（docker-compose.yml）
ports:
  - "8081:8080"  # 改为8081或其他端口
```

### 问题3：网络问题（中国大陆）
```bash
# 错误：timeout或connection refused
```

**解决**：配置Docker镜像加速

```bash
# 创建配置文件
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
EOF

# 重启Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 📚 相关文档

- [Docker官方文档](https://docs.docker.com/)
- [Docker Compose官方文档](https://docs.docker.com/compose/)
- [项目Docker部署指南](./DOCKER_DEPLOY.md)
- [快速部署指南](./DOCKER_README.md)

---

## 🎉 完成部署

安装完成后，使用以下命令部署项目：

```bash
# 进入项目目录
cd /path/to/wps_open_api

# 启动服务（V2命令）
docker compose up -d --build

# 或使用V1命令（如果安装了V1）
docker-compose up -d --build

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f web

# 访问系统
# http://your-server:8080
# 用户名: admin
# 密码: admin123456
```

---

**更新时间**: 2026-01-30  
**适用系统**: Linux (Ubuntu/Debian/CentOS/RHEL)
