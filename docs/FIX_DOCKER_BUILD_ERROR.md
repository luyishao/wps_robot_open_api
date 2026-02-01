# 🔧 Docker镜像拉取错误修复指南

## ❌ 错误信息

```
failed to solve: python:3.12: failed to resolve source metadata
failed commit on ref "unknown-sha256:..."
failed size validation: 7948 != 7640: failed precondition
```

## 🎯 问题原因

这个错误通常由以下原因引起：
1. **网络不稳定** - 镜像下载不完整
2. **Docker缓存损坏** - 本地缓存文件损坏
3. **镜像仓库问题** - Docker Hub临时故障
4. **磁盘空间不足** - 无法完成镜像写入
5. **Docker守护进程问题** - Docker服务异常

## ✅ 解决方案

### 方案1：清理Docker缓存并重试（首选）⭐

```bash
# 1. 清理构建缓存
docker builder prune -a -f

# 2. 清理所有未使用的资源
docker system prune -a -f

# 3. 重新构建
docker compose build --no-cache

# 4. 启动
docker compose up -d
```

---

### 方案2：手动拉取镜像

```bash
# 1. 删除损坏的镜像（如果存在）
docker rmi python:3.12 -f

# 2. 手动拉取镜像
docker pull python:3.12

# 3. 如果成功，重新构建项目
docker compose build

# 4. 启动
docker compose up -d
```

---

### 方案3：配置镜像加速（中国大陆推荐）⭐

如果您在中国大陆，配置镜像加速器可以解决大部分网络问题：

#### 3.1 创建/编辑Docker配置

```bash
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

#### 3.2 添加镜像源配置

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com",
    "https://docker.m.daocloud.io"
  ]
}
```

#### 3.3 重启Docker服务

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### 3.4 验证配置

```bash
docker info | grep -A 10 "Registry Mirrors"
```

#### 3.5 重新构建

```bash
cd /path/to/wps_open_api
docker compose build --no-cache
docker compose up -d
```

---

### 方案4：使用不同版本的基础镜像

修改 `Dockerfile`，使用稍旧或更新的Python版本：

**选项A：使用Python 3.12 标准版（当前使用）**

```dockerfile
# 当前已使用标准版
FROM python:3.12
```

**选项B：使用Python 3.11 标准版**

```dockerfile
FROM python:3.11
```

**选项C：使用Slim版本（更小）**

```dockerfile
FROM python:3.12-slim
# 注意：slim版本缺少一些系统工具
```

**选项D：使用Alpine版本（最小）**

```dockerfile
FROM python:3.12-alpine

# 注意：Alpine需要额外安装编译工具
RUN apk add --no-cache gcc musl-dev linux-headers
```

修改后重新构建：

```bash
docker compose build --no-cache
docker compose up -d
```

---

### 方案5：检查磁盘空间

```bash
# 检查磁盘空间
df -h

# 如果空间不足，清理Docker资源
docker system df  # 查看Docker占用空间
docker system prune -a -f --volumes  # 清理所有未使用的资源（包括卷）

# 清理系统日志（如果需要）
sudo journalctl --vacuum-time=3d
```

---

### 方案6：重启Docker服务

```bash
# Ubuntu/Debian
sudo systemctl restart docker

# 检查Docker状态
sudo systemctl status docker

# 查看Docker日志
sudo journalctl -u docker -n 50
```

---

### 方案7：完全重置Docker（慎用）

⚠️ **警告**：这将删除所有镜像、容器、卷和网络！

```bash
# 停止Docker
sudo systemctl stop docker

# 删除Docker数据目录
sudo rm -rf /var/lib/docker

# 重启Docker
sudo systemctl start docker

# 重新构建
cd /path/to/wps_open_api
docker compose build
docker compose up -d
```

---

## 🔍 问题排查步骤

### 1. 检查网络连接

```bash
# 测试Docker Hub连接
ping hub.docker.com

# 测试DNS解析
nslookup hub.docker.com

# 测试镜像拉取（直接下载）
wget https://registry-1.docker.io/v2/
```

### 2. 检查Docker状态

```bash
# Docker服务状态
sudo systemctl status docker

# Docker版本
docker --version

# Docker信息
docker info
```

### 3. 检查磁盘空间

```bash
# 整体磁盘空间
df -h

# Docker占用空间
docker system df

# 具体到Docker数据目录
du -sh /var/lib/docker
```

### 4. 查看Docker日志

```bash
# 系统日志
sudo journalctl -u docker -n 100

# 或查看Docker日志文件
sudo tail -f /var/log/docker.log  # 如果存在
```

---

## 📝 推荐解决流程

### 快速修复（按顺序尝试）

#### Step 1: 清理缓存
```bash
docker builder prune -a -f
docker compose build --no-cache
docker compose up -d
```

#### Step 2: 如果失败，配置镜像加速
```bash
# 创建配置文件
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

# 重启Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 重新构建
docker compose build --no-cache
docker compose up -d
```

#### Step 3: 如果还失败，手动拉取镜像
```bash
# 删除旧镜像
docker rmi python:3.12 -f

# 重新拉取
docker pull python:3.12

# 构建
docker compose build
docker compose up -d
```

#### Step 4: 如果仍然失败，更换基础镜像版本
编辑 `Dockerfile`，将第一行改为：
```dockerfile
FROM python:3.11
```

然后重新构建。

---

## 🌐 国内镜像源推荐

### 阿里云（需要注册）
```
https://<your_id>.mirror.aliyuncs.com
```
注册地址：https://cr.console.aliyun.com/

### 中国科技大学
```
https://docker.mirrors.ustc.edu.cn
```

### 网易云
```
https://hub-mirror.c.163.com
```

### 腾讯云
```
https://mirror.ccs.tencentyun.com
```

### DaoCloud
```
https://docker.m.daocloud.io
```

---

## 🔧 修改后的Dockerfile示例

如果您想使用更稳定的配置，可以修改Dockerfile：

### 选项1：使用Python 3.11（备用版本）

```dockerfile
FROM python:3.11

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=wps_robot.settings

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

COPY . .

RUN mkdir -p media/hook_scripts staticfiles

RUN python manage.py collectstatic --noinput || true

RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--timeout", "60", "wps_robot.wsgi:application"]
```

### 选项2：使用国内PyPI镜像

```dockerfile
FROM python:3.12

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=wps_robot.settings

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# 使用清华大学PyPI镜像
RUN pip install --no-cache-dir -r requirements.txt \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip install --no-cache-dir gunicorn \
    -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY . .

RUN mkdir -p media/hook_scripts staticfiles

RUN python manage.py collectstatic --noinput || true

RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--timeout", "60", "wps_robot.wsgi:application"]
```

---

## ⚡ 完整解决方案（一键脚本）

创建修复脚本 `fix-docker-build.sh`：

```bash
#!/bin/bash

echo "==================================="
echo "Docker镜像构建问题修复工具"
echo "==================================="

# 1. 清理缓存
echo "1. 清理Docker缓存..."
docker builder prune -a -f
docker system prune -a -f

# 2. 配置镜像加速（仅限中国大陆）
echo "2. 配置镜像加速..."
read -p "是否配置中国大陆镜像加速？(y/n): " choice
if [ "$choice" = "y" ]; then
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "镜像加速已配置并重启Docker"
    sleep 3
fi

# 3. 手动拉取镜像
echo "3. 手动拉取Python基础镜像..."
docker pull python:3.12 || docker pull python:3.11

# 4. 重新构建
echo "4. 重新构建项目..."
docker compose build --no-cache

# 5. 启动
echo "5. 启动容器..."
docker compose up -d

echo "==================================="
echo "修复完成！"
echo "查看状态: docker compose ps"
echo "查看日志: docker compose logs -f web"
echo "==================================="
```

使用脚本：

```bash
chmod +x fix-docker-build.sh
./fix-docker-build.sh
```

---

## 📞 获取帮助

如果问题仍未解决：

1. **查看完整错误日志**：
   ```bash
   docker compose build 2>&1 | tee build-error.log
   ```

2. **检查Docker版本**：
   ```bash
   docker --version
   docker compose version
   ```

3. **查看系统信息**：
   ```bash
   docker info
   df -h
   free -h
   ```

---

**更新时间**: 2026-01-30  
**适用系统**: Linux (Ubuntu/Debian/CentOS/RHEL)
