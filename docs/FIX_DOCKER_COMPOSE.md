## ❌ 错误：bash: docker-compose: command not found

### 🎯 快速解决方案

#### 方案1：使用Docker Compose V2（推荐）⭐

```bash
# 检查是否已安装
docker compose version

# 如果有输出，直接使用新命令
docker compose up -d --build
```

**命令对比**：
- ❌ 旧：`docker-compose`（连字符）
- ✅ 新：`docker compose`（空格）

---

#### 方案2：安装Docker Compose

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
docker compose version  # 验证
```

**CentOS/RHEL**:
```bash
sudo yum install docker-compose-plugin
docker compose version  # 验证
```

**手动安装V1**:
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version  # 验证
```

---

#### 方案3：创建别名

```bash
# 如果V2已安装，创建别名兼容V1命令
alias docker-compose='docker compose'

# 永久生效
echo "alias docker-compose='docker compose'" >> ~/.bashrc
source ~/.bashrc
```

---

### 📚 详细文档

完整安装指南：[INSTALL_DOCKER_COMPOSE.md](./INSTALL_DOCKER_COMPOSE.md)

---

### 🚀 部署项目

```bash
# 进入项目目录
cd /path/to/wps_open_api

# 使用V2命令（推荐）
docker compose up -d --build

# 或使用V1命令
docker-compose up -d --build
```

---

**更新时间**: 2026-01-30
