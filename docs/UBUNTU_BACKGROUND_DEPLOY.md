# Ubuntu后台运行指南

## 📋 目录

1. [快速开始 - 使用nohup](#方案1使用nohup快速启动)
2. [使用systemd服务（推荐）](#方案2使用systemd服务推荐)
3. [使用Supervisor](#方案3使用supervisor)
4. [使用screen/tmux](#方案4使用screentmux)
5. [Docker部署](#方案5docker部署)

---

## 方案1：使用nohup（快速启动）

### 🚀 最简单的方法

```bash
# 启动Gunicorn（Linux推荐）
nohup gunicorn --bind 0.0.0.0:80 --workers 4 --timeout 60 wps_robot.wsgi:application > logs/gunicorn.log 2>&1 &

# 或使用Waitress
nohup waitress-serve --host=0.0.0.0 --port=80 --threads=4 wps_robot.wsgi:application > logs/waitress.log 2>&1 &

# 记录进程ID
echo $! > gunicorn.pid
```

### 查看日志
```bash
tail -f logs/gunicorn.log
```

### 停止服务
```bash
# 方法1：使用PID文件
kill $(cat gunicorn.pid)

# 方法2：查找进程
ps aux | grep gunicorn
kill -9 <PID>
```

### 优点
- ✅ 简单快速
- ✅ 无需额外配置

### 缺点
- ❌ 崩溃后不会自动重启
- ❌ 系统重启后需要手动启动
- ❌ 不便于管理

---

## 方案2：使用systemd服务（推荐）

### 📦 最专业的方法

systemd是Ubuntu的系统服务管理器，可以实现：
- ✅ 开机自启动
- ✅ 崩溃自动重启
- ✅ 统一的服务管理
- ✅ 完善的日志系统

### 1. 创建服务配置文件

创建 `/etc/systemd/system/wps-robot.service`：

```ini
[Unit]
Description=WPS Robot Open API Service
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/path/to/wps_robot_open_api
Environment="PATH=/path/to/venv/bin"
Environment="PYTHONUNBUFFERED=1"

# Gunicorn启动命令
ExecStart=/path/to/venv/bin/gunicorn \
    --bind 0.0.0.0:80 \
    --workers 4 \
    --timeout 60 \
    --access-logfile /path/to/wps_robot_open_api/logs/access.log \
    --error-logfile /path/to/wps_robot_open_api/logs/error.log \
    --log-level info \
    wps_robot.wsgi:application

# 重启策略
Restart=always
RestartSec=10

# 安全设置
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

### 2. 安装和启动服务

```bash
# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start wps-robot

# 设置开机自启动
sudo systemctl enable wps-robot

# 查看服务状态
sudo systemctl status wps-robot

# 查看日志
sudo journalctl -u wps-robot -f
```

### 3. 服务管理命令

```bash
# 启动服务
sudo systemctl start wps-robot

# 停止服务
sudo systemctl stop wps-robot

# 重启服务
sudo systemctl restart wps-robot

# 重新加载配置
sudo systemctl reload wps-robot

# 查看状态
sudo systemctl status wps-robot

# 查看日志
sudo journalctl -u wps-robot -n 100 -f

# 禁用开机自启动
sudo systemctl disable wps-robot
```

### 4. 完整配置示例

假设项目路径为 `/opt/wps_robot_open_api`，使用虚拟环境：

```ini
[Unit]
Description=WPS Robot Open API Service
After=network.target postgresql.service redis.service
Wants=postgresql.service redis.service

[Service]
Type=notify
User=wpsrobot
Group=wpsrobot
WorkingDirectory=/opt/wps_robot_open_api
Environment="PATH=/opt/wps_robot_open_api/venv/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="DJANGO_SETTINGS_MODULE=wps_robot.settings"

ExecStart=/opt/wps_robot_open_api/venv/bin/gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --worker-class sync \
    --threads 2 \
    --timeout 60 \
    --keepalive 5 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --access-logfile /opt/wps_robot_open_api/logs/gunicorn-access.log \
    --error-logfile /opt/wps_robot_open_api/logs/gunicorn-error.log \
    --log-level info \
    --pid /opt/wps_robot_open_api/gunicorn.pid \
    wps_robot.wsgi:application

# 重启策略
Restart=always
RestartSec=10
StartLimitInterval=200
StartLimitBurst=5

# 资源限制
LimitNOFILE=65535
LimitNPROC=4096

# 安全设置
PrivateTmp=true
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/wps_robot_open_api/logs /opt/wps_robot_open_api/media

[Install]
WantedBy=multi-user.target
```

---

## 方案3：使用Supervisor

### 🎛️ 进程管理工具

Supervisor是一个进程监控工具，适合管理多个服务。

### 1. 安装Supervisor

```bash
sudo apt update
sudo apt install supervisor
```

### 2. 创建配置文件

创建 `/etc/supervisor/conf.d/wps-robot.conf`：

```ini
[program:wps-robot]
command=/opt/wps_robot_open_api/venv/bin/gunicorn --bind 0.0.0.0:80 --workers 4 --timeout 60 wps_robot.wsgi:application
directory=/opt/wps_robot_open_api
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/opt/wps_robot_open_api/logs/supervisor.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=PATH="/opt/wps_robot_open_api/venv/bin",PYTHONUNBUFFERED="1"
```

### 3. 管理命令

```bash
# 重新加载配置
sudo supervisorctl reread
sudo supervisorctl update

# 启动服务
sudo supervisorctl start wps-robot

# 停止服务
sudo supervisorctl stop wps-robot

# 重启服务
sudo supervisorctl restart wps-robot

# 查看状态
sudo supervisorctl status wps-robot

# 查看日志
sudo supervisorctl tail -f wps-robot

# 查看所有服务
sudo supervisorctl status
```

---

## 方案4：使用screen/tmux

### 🖥️ 终端复用工具

适合临时测试或开发环境。

### 使用screen

```bash
# 安装screen
sudo apt install screen

# 创建新会话
screen -S wps-robot

# 在会话中启动服务
cd /opt/wps_robot_open_api
gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application

# 分离会话: Ctrl+A, 然后按 D

# 重新连接
screen -r wps-robot

# 列出所有会话
screen -ls

# 终止会话
screen -X -S wps-robot quit
```

### 使用tmux

```bash
# 安装tmux
sudo apt install tmux

# 创建新会话
tmux new -s wps-robot

# 在会话中启动服务
cd /opt/wps_robot_open_api
gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application

# 分离会话: Ctrl+B, 然后按 D

# 重新连接
tmux attach -t wps-robot

# 列出所有会话
tmux ls

# 终止会话
tmux kill-session -t wps-robot
```

---

## 方案5：Docker部署

### 🐳 容器化部署

项目已包含 `docker-compose.yml`，可以直接使用。

```bash
# 启动服务（后台运行）
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 停止并删除容器
docker-compose down
```

---

## 📝 完整部署脚本

### 创建自动化部署脚本

创建 `deploy_ubuntu.sh`：

```bash
#!/bin/bash

set -e

PROJECT_DIR="/opt/wps_robot_open_api"
VENV_DIR="$PROJECT_DIR/venv"
USER="wpsrobot"
GROUP="wpsrobot"

echo "========================================"
echo "WPS Robot Open API - Ubuntu部署脚本"
echo "========================================"

# 1. 创建用户
echo "[1/8] 创建系统用户..."
if ! id "$USER" &>/dev/null; then
    sudo useradd -r -s /bin/bash -d $PROJECT_DIR $USER
    echo "用户 $USER 已创建"
fi

# 2. 安装系统依赖
echo "[2/8] 安装系统依赖..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git nginx

# 3. 创建项目目录
echo "[3/8] 设置项目目录..."
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$GROUP $PROJECT_DIR

# 4. 复制项目文件（假设当前在项目目录）
echo "[4/8] 复制项目文件..."
sudo cp -r . $PROJECT_DIR/
sudo chown -R $USER:$GROUP $PROJECT_DIR

# 5. 创建虚拟环境
echo "[5/8] 创建Python虚拟环境..."
sudo -u $USER python3 -m venv $VENV_DIR
sudo -u $USER $VENV_DIR/bin/pip install --upgrade pip
sudo -u $USER $VENV_DIR/bin/pip install -r $PROJECT_DIR/requirements.txt
sudo -u $USER $VENV_DIR/bin/pip install gunicorn

# 6. 创建日志目录
echo "[6/8] 创建日志目录..."
sudo mkdir -p $PROJECT_DIR/logs
sudo chown -R $USER:$GROUP $PROJECT_DIR/logs

# 7. 创建systemd服务
echo "[7/8] 配置systemd服务..."
sudo tee /etc/systemd/system/wps-robot.service > /dev/null <<EOF
[Unit]
Description=WPS Robot Open API Service
After=network.target

[Service]
Type=notify
User=$USER
Group=$GROUP
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$VENV_DIR/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONUNBUFFERED=1"

ExecStart=$VENV_DIR/bin/gunicorn \\
    --bind 0.0.0.0:8000 \\
    --workers 4 \\
    --timeout 60 \\
    --access-logfile $PROJECT_DIR/logs/gunicorn-access.log \\
    --error-logfile $PROJECT_DIR/logs/gunicorn-error.log \\
    --log-level info \\
    wps_robot.wsgi:application

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 8. 启动服务
echo "[8/8] 启动服务..."
sudo systemctl daemon-reload
sudo systemctl enable wps-robot
sudo systemctl start wps-robot

echo ""
echo "========================================"
echo "部署完成！"
echo "========================================"
echo ""
echo "服务状态检查："
sudo systemctl status wps-robot --no-pager
echo ""
echo "常用命令："
echo "  查看状态: sudo systemctl status wps-robot"
echo "  查看日志: sudo journalctl -u wps-robot -f"
echo "  重启服务: sudo systemctl restart wps-robot"
echo "  停止服务: sudo systemctl stop wps-robot"
echo ""
echo "访问地址: http://your-server-ip:8000"
echo ""
```

使用方法：

```bash
# 给脚本添加执行权限
chmod +x deploy_ubuntu.sh

# 运行部署脚本
sudo ./deploy_ubuntu.sh
```

---

## 🔧 Nginx反向代理配置

### 为什么使用Nginx

1. **端口80/443**：不需要root权限
2. **负载均衡**：可以运行多个Gunicorn实例
3. **静态文件**：高效处理静态资源
4. **SSL/TLS**：支持HTTPS
5. **缓存**：提升性能

### Nginx配置

创建 `/etc/nginx/sites-available/wps-robot`：

```nginx
upstream wps_robot {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名或IP

    client_max_body_size 20M;

    # 访问日志
    access_log /var/log/nginx/wps-robot-access.log;
    error_log /var/log/nginx/wps-robot-error.log;

    # 静态文件
    location /static/ {
        alias /opt/wps_robot_open_api/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 媒体文件
    location /media/ {
        alias /opt/wps_robot_open_api/media/;
        expires 30d;
    }

    # 代理到Django
    location / {
        proxy_pass http://wps_robot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 支持分块传输编码
        proxy_http_version 1.1;
        proxy_request_buffering off;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### 启用Nginx配置

```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/wps-robot /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx

# 设置开机自启动
sudo systemctl enable nginx
```

---

## 🚀 快速启动命令

### 方法1：systemd（推荐）
```bash
sudo systemctl start wps-robot
```

### 方法2：nohup
```bash
nohup gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application > logs/gunicorn.log 2>&1 &
```

### 方法3：screen
```bash
screen -dmS wps-robot bash -c 'gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application'
```

---

## 📊 方案对比

| 方案 | 难度 | 自动重启 | 开机启动 | 日志管理 | 推荐场景 |
|-----|------|---------|---------|---------|---------|
| nohup | ⭐ | ❌ | ❌ | ⚠️ | 临时测试 |
| screen/tmux | ⭐⭐ | ❌ | ❌ | ⚠️ | 开发调试 |
| Supervisor | ⭐⭐⭐ | ✅ | ✅ | ✅ | 多服务管理 |
| systemd | ⭐⭐⭐⭐ | ✅ | ✅ | ✅✅ | **生产环境（推荐）** |
| Docker | ⭐⭐⭐ | ✅ | ✅ | ✅ | 容器化部署 |

---

## 🔍 监控和维护

### 查看服务状态
```bash
# systemd
sudo systemctl status wps-robot

# Supervisor
sudo supervisorctl status wps-robot

# 进程查看
ps aux | grep gunicorn
netstat -tlnp | grep :80
```

### 查看日志
```bash
# systemd日志
sudo journalctl -u wps-robot -f

# 应用日志
tail -f /opt/wps_robot_open_api/logs/gunicorn-access.log
tail -f /opt/wps_robot_open_api/logs/gunicorn-error.log

# Django日志
tail -f /opt/wps_robot_open_api/logs/django.log
```

### 性能监控
```bash
# 查看资源使用
htop
top -p $(pgrep -f gunicorn | head -1)

# 查看连接数
ss -tan | grep :80 | wc -l
```

---

## 🛠️ 故障排除

### 问题1：服务启动失败
```bash
# 查看详细错误
sudo journalctl -u wps-robot -n 50 --no-pager

# 检查端口占用
sudo netstat -tlnp | grep :80

# 检查文件权限
ls -la /opt/wps_robot_open_api
```

### 问题2：502 Bad Gateway
```bash
# 检查Gunicorn是否运行
sudo systemctl status wps-robot

# 检查Nginx配置
sudo nginx -t

# 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log
```

### 问题3：权限问题
```bash
# 确保用户有权限访问项目目录
sudo chown -R wpsrobot:wpsrobot /opt/wps_robot_open_api

# 确保日志目录可写
sudo chmod 755 /opt/wps_robot_open_api/logs
```

---

## 📚 相关文档

- [分块传输编码问题修复](FIX_400_CHUNKED_ENCODING.md)
- [端口配置说明](PORT_CHANGE_80.md)
- [日志管理指南](LOGS_GUIDE.md)
- [Web日志查看](WEB_LOGS_FEATURE.md)

---

**推荐方案：systemd + Nginx + Gunicorn** ⭐⭐⭐⭐⭐

这是最稳定、最专业的部署方式，适合生产环境使用。
