# WPS机器人系统 Docker快速部署

## 🚀 快速开始（5分钟部署）

### 1. 确认环境
```bash
docker --version  # 需要 20.10+
docker compose version  # V2，或
docker-compose --version  # V1
```

**如果提示 `command not found`**：请查看 [安装指南](./INSTALL_DOCKER_COMPOSE.md)

### 2. 克隆/上传项目
```bash
cd /path/to/wps_open_api
ls  # 确认有 Dockerfile 和 docker-compose.yml
```

### 3. 一键启动
```bash
# Docker Compose V2（推荐）
docker compose up -d --build

# 或 Docker Compose V1
docker-compose up -d --build
```

### 4. 访问系统
```
URL: http://your-server:8080
账号: admin
密码: admin123456
```

## 📋 主要文件

| 文件 | 说明 |
|-----|------|
| `Dockerfile` | 镜像构建文件 |
| `docker-compose.yml` | 编排配置 |
| `.dockerignore` | 构建忽略文件 |
| `docker-entrypoint.sh` | 启动脚本 |

## 🛠️ 常用命令

```bash
# === V2命令（推荐） ===
docker compose up -d          # 启动
docker compose stop           # 停止
docker compose restart        # 重启
docker compose logs -f web    # 查看日志
docker compose exec web bash  # 进入容器

# === V1命令（兼容） ===
docker-compose up -d
docker-compose stop
docker-compose restart
docker-compose logs -f web
docker-compose exec web bash

# 更新
docker compose down
git pull  # 或上传新代码
docker compose up -d --build
```

## 📦 数据持久化

自动挂载以下目录：
- `./db.sqlite3` - 数据库
- `./media/` - 上传文件
- `./staticfiles/` - 静态文件

## ⚠️ 重要提示

1. **端口**: 默认使用8080端口，可在docker-compose.yml修改
2. **初始账号**: admin/admin123456，首次登录后请修改密码
3. **备份**: 定期备份 db.sqlite3 和 media/ 目录
4. **生产环境**: 建议使用Nginx反向代理并启用HTTPS

## 📚 详细文档

完整部署指南请查看: [DOCKER_DEPLOY.md](./DOCKER_DEPLOY.md)

---

**快速问题排查**:
- 端口占用: 修改 docker-compose.yml 中的端口号
- 无法访问: 检查防火墙设置
- 日志查看: `docker-compose logs -f web`
