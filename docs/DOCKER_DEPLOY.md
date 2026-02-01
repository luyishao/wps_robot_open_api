# 🐳 Docker部署指南

## 📋 目录
- [快速开始](#快速开始)
- [部署文件说明](#部署文件说明)
- [详细部署步骤](#详细部署步骤)
- [配置说明](#配置说明)
- [常用命令](#常用命令)
- [生产环境优化](#生产环境优化)
- [故障排查](#故障排查)

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose V2 或 V1

**检查安装**：
```bash
docker --version
docker compose version  # V2 (推荐)
# 或
docker-compose --version  # V1
```

### 一键部署

```bash
# 1. 克隆或上传项目到服务器
cd /path/to/wps_open_api

# 2. 构建并启动（Docker Compose V2）
docker compose up -d --build

# 或使用V1命令
docker-compose up -d --build

# 3. 查看日志
docker compose logs -f web
# 或
docker-compose logs -f web

# 4. 访问应用
# http://your-server:8080
# 默认账号: admin / admin123456
```

**注意**：
- 如果遇到 `docker-compose: command not found` 错误，请查看 [Docker Compose安装指南](./INSTALL_DOCKER_COMPOSE.md)
- Docker Compose V2使用 `docker compose`（空格），V1使用 `docker-compose`（连字符）

## 📁 部署文件说明

### 核心文件

| 文件 | 说明 |
|-----|------|
| `Dockerfile` | Docker镜像构建文件 |
| `docker-compose.yml` | Docker Compose配置 |
| `.dockerignore` | 构建时忽略的文件 |
| `docker-entrypoint.sh` | 容器启动脚本 |
| `requirements.txt` | Python依赖 |

### Dockerfile 特性

- ✅ 基于 Python 3.12 标准镜像（功能完整）
- ✅ 使用 Gunicorn 作为WSGI服务器
- ✅ 非root用户运行（安全）
- ✅ 多阶段构建优化
- ✅ 健康检查支持

### docker-compose.yml 特性

- ✅ 自动重启
- ✅ 数据持久化（数据库、上传文件）
- ✅ 健康检查
- ✅ 端口映射
- ✅ 可选Nginx反向代理

## 🔧 详细部署步骤

### 步骤1：准备项目文件

```bash
# 确保项目结构完整
ls -la
# 应该看到:
# - manage.py
# - requirements.txt
# - wps_robot/
# - robots/
# - Dockerfile
# - docker-compose.yml
```

### 步骤2：检查配置

**检查 settings.py**：

```python
# wps_robot/settings.py

# 生产环境建议
DEBUG = False  # 生产环境设置为False
ALLOWED_HOSTS = ['*']  # 或指定具体域名

# 静态文件
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATIC_URL = '/static/'

# 媒体文件
MEDIA_ROOT = BASE_DIR / 'media'
MEDIA_URL = '/media/'

# 安全设置（生产环境）
# SECURE_SSL_REDIRECT = True
# SESSION_COOKIE_SECURE = True
# CSRF_COOKIE_SECURE = True
```

### 步骤3：构建镜像

```bash
# 构建镜像
docker-compose build

# 查看镜像
docker images | grep wps_robot
```

### 步骤4：启动容器

```bash
# 启动（后台运行）
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs -f web
```

### 步骤5：初始化数据库

```bash
# 执行数据库迁移
docker-compose exec web python manage.py migrate

# 创建超级用户（如果使用docker-entrypoint.sh会自动创建）
docker-compose exec web python manage.py createsuperuser

# 或使用已自动创建的账号
# 用户名: admin
# 密码: admin123456
```

### 步骤6：访问应用

```
http://your-server-ip:8080
```

## ⚙️ 配置说明

### 端口配置

**修改端口**（docker-compose.yml）：

```yaml
services:
  web:
    ports:
      - "8080:8080"  # 改为 "你的端口:8080"
```

### 环境变量

创建 `.env` 文件：

```bash
# .env
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DATABASE_URL=sqlite:///db.sqlite3
```

**使用环境变量**（docker-compose.yml）：

```yaml
services:
  web:
    env_file:
      - .env
```

### 数据持久化

**重要目录挂载**：

```yaml
volumes:
  - ./db.sqlite3:/app/db.sqlite3       # 数据库
  - ./media:/app/media                 # 上传文件
  - ./staticfiles:/app/staticfiles     # 静态文件
```

### Worker数量调整

**修改Gunicorn workers**：

```yaml
command: gunicorn --bind 0.0.0.0:8080 --workers 4 --timeout 60 wps_robot.wsgi:application
```

推荐workers数量：`2 * CPU核心数 + 1`

## 🛠️ 常用命令

### 容器管理

```bash
# 启动
docker-compose up -d

# 停止
docker-compose stop

# 重启
docker-compose restart

# 停止并删除容器
docker-compose down

# 停止并删除容器、数据卷
docker-compose down -v
```

### 日志查看

```bash
# 查看所有日志
docker-compose logs

# 实时查看日志
docker-compose logs -f web

# 查看最近100行
docker-compose logs --tail=100 web
```

### 进入容器

```bash
# 进入容器shell
docker-compose exec web bash

# 执行Django命令
docker-compose exec web python manage.py shell
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

### 数据备份

```bash
# 备份数据库
docker-compose exec web python manage.py dumpdata > backup.json

# 或直接复制数据库文件
cp db.sqlite3 db.sqlite3.backup.$(date +%Y%m%d_%H%M%S)

# 备份上传的文件
tar -czf media_backup.tar.gz media/
```

### 数据恢复

```bash
# 恢复数据库
docker-compose exec -T web python manage.py loaddata < backup.json

# 或恢复数据库文件
docker-compose down
cp db.sqlite3.backup.20260130 db.sqlite3
docker-compose up -d
```

### 更新部署

```bash
# 1. 停止容器
docker-compose down

# 2. 更新代码
git pull  # 或上传新代码

# 3. 重新构建并启动
docker-compose up -d --build

# 4. 执行迁移（如有数据库变更）
docker-compose exec web python manage.py migrate
```

## 🚀 生产环境优化

### 使用Nginx反向代理

**1. 创建 nginx.conf**：

```nginx
events {
    worker_connections 1024;
}

http {
    upstream django {
        server web:8080;
    }

    server {
        listen 80;
        server_name yourdomain.com;
        
        client_max_body_size 10M;

        location /static/ {
            alias /app/staticfiles/;
        }

        location /media/ {
            alias /app/media/;
        }

        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

**2. 启用Nginx**（docker-compose.yml）：

```yaml
services:
  web:
    # ... 保持不变

  nginx:
    image: nginx:alpine
    container_name: wps_robot_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./staticfiles:/app/staticfiles:ro
      - ./media:/app/media:ro
    depends_on:
      - web
    restart: unless-stopped
```

### 使用PostgreSQL

**1. 修改 docker-compose.yml**：

```yaml
services:
  db:
    image: postgres:15-alpine
    container_name: wps_robot_db
    environment:
      POSTGRES_DB: wps_robot
      POSTGRES_USER: wps_user
      POSTGRES_PASSWORD: your_password_here
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  web:
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://wps_user:your_password_here@db:5432/wps_robot

volumes:
  postgres_data:
```

**2. 安装psycopg2**（requirements.txt）：

```txt
psycopg2-binary==2.9.9
```

**3. 修改 settings.py**：

```python
import os
import dj_database_url

DATABASES = {
    'default': dj_database_url.config(
        default='sqlite:///db.sqlite3',
        conn_max_age=600
    )
}
```

### SSL/HTTPS支持

**使用 Certbot**：

```yaml
services:
  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    command: certonly --webroot --webroot-path=/var/www/certbot --email your@email.com --agree-tos --no-eff-email -d yourdomain.com
```

### 资源限制

```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## 🔍 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker-compose logs web

# 检查容器状态
docker-compose ps

# 查看容器资源使用
docker stats
```

### 端口被占用

```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux
lsof -i :8080
kill -9 <PID>

# 或修改docker-compose.yml中的端口
```

### 数据库迁移失败

```bash
# 进入容器
docker-compose exec web bash

# 手动执行迁移
python manage.py migrate

# 查看迁移状态
python manage.py showmigrations

# 如果需要，删除迁移记录重新迁移
python manage.py migrate --fake
```

### 静态文件404

```bash
# 收集静态文件
docker-compose exec web python manage.py collectstatic --noinput

# 检查目录权限
docker-compose exec web ls -la staticfiles/

# 如果使用Nginx，检查配置
docker-compose exec nginx nginx -t
```

### 权限问题

```bash
# 修改文件所有者
sudo chown -R 1000:1000 media/ db.sqlite3

# 或在Dockerfile中调整UID
```

### 内存不足

```bash
# 查看资源使用
docker stats

# 减少workers数量
command: gunicorn --bind 0.0.0.0:8080 --workers 2 ...

# 或增加系统资源
```

## 📊 监控和维护

### 健康检查

容器自带健康检查：

```yaml
healthcheck:
  test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8080/login/', timeout=5)"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### 日志管理

**限制日志大小**（docker-compose.yml）：

```yaml
services:
  web:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 定期备份

**创建备份脚本** `backup.sh`：

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

# 备份数据库
cp db.sqlite3 "$BACKUP_DIR/db_$DATE.sqlite3"

# 备份上传文件
tar -czf "$BACKUP_DIR/media_$DATE.tar.gz" media/

# 删除7天前的备份
find $BACKUP_DIR -name "*.sqlite3" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

**设置定时任务**：

```bash
# 编辑crontab
crontab -e

# 每天凌晨2点备份
0 2 * * * /path/to/backup.sh
```

## 🎯 最佳实践

1. **不要在容器中存储重要数据**
   - 使用volumes持久化数据库和上传文件

2. **使用环境变量管理配置**
   - 敏感信息不要写在代码中

3. **定期备份**
   - 数据库和上传文件都要备份

4. **监控日志**
   - 定期查看日志，及时发现问题

5. **更新镜像**
   - 定期更新基础镜像和依赖包

6. **使用Nginx**
   - 生产环境建议使用Nginx作为反向代理

7. **启用HTTPS**
   - 生产环境必须使用HTTPS

8. **资源限制**
   - 设置适当的CPU和内存限制

## 📝 快速参考

### 完整启动流程

```bash
# 1. 准备
cd /path/to/wps_open_api

# 2. 构建
docker-compose build

# 3. 启动
docker-compose up -d

# 4. 检查
docker-compose ps
docker-compose logs -f web

# 5. 初始化（如需要）
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser

# 6. 访问
# http://your-server:8080
```

### 常见问题快速解决

| 问题 | 命令 |
|------|------|
| 查看日志 | `docker-compose logs -f web` |
| 重启容器 | `docker-compose restart` |
| 进入容器 | `docker-compose exec web bash` |
| 执行迁移 | `docker-compose exec web python manage.py migrate` |
| 收集静态文件 | `docker-compose exec web python manage.py collectstatic` |
| 备份数据库 | `cp db.sqlite3 db.sqlite3.backup` |
| 查看容器状态 | `docker-compose ps` |
| 停止容器 | `docker-compose down` |

---

**文档版本**: v1.0  
**更新日期**: 2026-01-30  
**适用系统**: WPS协作后台机器人Django项目
