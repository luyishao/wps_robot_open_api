# Ubuntu后台运行 - 快速参考

## 🚀 最快启动方式

### 1. 使用启动脚本（推荐）

```bash
# 给脚本添加执行权限
chmod +x start_ubuntu.sh

# 启动服务
./start_ubuntu.sh start

# 查看状态
./start_ubuntu.sh status

# 查看日志
./start_ubuntu.sh logs

# 停止服务
./start_ubuntu.sh stop
```

---

## 📝 三种启动方式对比

### 方式1：nohup（默认）
```bash
./start_ubuntu.sh start
```
✅ 简单快速  
✅ 后台运行  
❌ 崩溃不会自动重启  
❌ 需要手动管理  

**适合**：快速测试、临时部署

---

### 方式2：screen
```bash
./start_ubuntu.sh start screen
```
✅ 可以随时重新连接终端  
✅ 方便调试  
❌ 崩溃不会自动重启  

**适合**：开发调试

**重新连接**：
```bash
screen -r wps-robot
```

---

### 方式3：systemd（生产环境推荐）
```bash
./start_ubuntu.sh start systemd
```
✅ 开机自启动  
✅ 崩溃自动重启  
✅ 完善的日志管理  
✅ 统一的服务管理  

**适合**：生产环境

**前提条件**：需要先配置systemd服务

---

## ⚙️ 配置systemd服务

### 1. 复制服务文件
```bash
sudo cp wps-robot.service /etc/systemd/system/
```

### 2. 修改配置文件
编辑 `/etc/systemd/system/wps-robot.service`，修改以下内容：

```ini
# 修改为实际路径
WorkingDirectory=/opt/wps_robot_open_api
Environment="PATH=/opt/wps_robot_open_api/venv/bin:..."
ExecStart=/opt/wps_robot_open_api/venv/bin/gunicorn ...
```

### 3. 启动服务
```bash
# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start wps-robot

# 设置开机自启动
sudo systemctl enable wps-robot

# 查看状态
sudo systemctl status wps-robot
```

---

## 🔧 常用命令速查

### nohup方式

```bash
# 启动
./start_ubuntu.sh start

# 停止
./start_ubuntu.sh stop

# 重启
./start_ubuntu.sh restart

# 状态
./start_ubuntu.sh status

# 日志
tail -f logs/gunicorn-access.log
tail -f logs/gunicorn-error.log
```

### screen方式

```bash
# 启动
./start_ubuntu.sh start screen

# 重新连接
screen -r wps-robot

# 分离会话（在screen内）
Ctrl+A, 然后按 D

# 查看所有会话
screen -ls

# 停止
./start_ubuntu.sh stop
```

### systemd方式

```bash
# 启动
sudo systemctl start wps-robot

# 停止
sudo systemctl stop wps-robot

# 重启
sudo systemctl restart wps-robot

# 状态
sudo systemctl status wps-robot

# 日志
sudo journalctl -u wps-robot -f

# 最近100行日志
sudo journalctl -u wps-robot -n 100

# 开机自启动
sudo systemctl enable wps-robot

# 禁用开机自启动
sudo systemctl disable wps-robot
```

---

## 🌐 使用Nginx反向代理

### 1. 安装Nginx
```bash
sudo apt update
sudo apt install nginx
```

### 2. 创建配置文件

创建 `/etc/nginx/sites-available/wps-robot`：

```nginx
upstream wps_robot {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://wps_robot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_request_buffering off;
    }
}
```

### 3. 启用配置
```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/wps-robot /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

**注意**：使用Nginx时，Gunicorn监听 `127.0.0.1:8000` 即可。

---

## 🔍 故障排查

### 问题1：端口被占用
```bash
# 查看占用端口的进程
sudo lsof -i :80
sudo netstat -tlnp | grep :80

# 停止占用进程
sudo kill -9 <PID>
```

### 问题2：服务无法启动
```bash
# 查看错误日志
tail -f logs/gunicorn-error.log

# 或systemd日志
sudo journalctl -u wps-robot -n 50
```

### 问题3：权限问题
```bash
# 确保用户有权限
sudo chown -R $USER:$USER /path/to/wps_robot_open_api

# 或使用www-data用户
sudo chown -R www-data:www-data /path/to/wps_robot_open_api
```

### 问题4：Gunicorn未安装
```bash
# 安装Gunicorn
pip install gunicorn

# 或在虚拟环境中
source venv/bin/activate
pip install gunicorn
```

---

## 📊 推荐配置

### 开发环境
```bash
# 使用screen，方便调试
./start_ubuntu.sh start screen
```

### 测试环境
```bash
# 使用nohup，快速启动
./start_ubuntu.sh start
```

### 生产环境
```bash
# 使用systemd + Nginx
# 1. 配置systemd服务
# 2. 配置Nginx反向代理
# 3. 启动服务
sudo systemctl start wps-robot
sudo systemctl enable wps-robot
```

---

## 🔐 安全建议

### 1. 使用非root用户
```bash
# 创建专用用户
sudo useradd -r -s /bin/bash -d /opt/wps_robot_open_api wpsrobot

# 设置目录权限
sudo chown -R wpsrobot:wpsrobot /opt/wps_robot_open_api
```

### 2. 使用Nginx处理80端口
- Gunicorn监听 `127.0.0.1:8000`（非特权端口）
- Nginx监听 `0.0.0.0:80`（需要root权限）
- 通过Nginx反向代理到Gunicorn

### 3. 配置防火墙
```bash
# 只允许Nginx访问Gunicorn
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 📚 相关文档

- **详细部署指南**：[UBUNTU_BACKGROUND_DEPLOY.md](UBUNTU_BACKGROUND_DEPLOY.md)
- **400错误修复**：[FIX_400_CHUNKED_ENCODING.md](FIX_400_CHUNKED_ENCODING.md)
- **日志管理**：[LOGS_GUIDE.md](LOGS_GUIDE.md)
- **快速开始**：[../README.md](../README.md)

---

## 💡 最佳实践

1. **开发测试**：使用 `screen` 方式，方便调试
2. **生产部署**：使用 `systemd` + `Nginx`，稳定可靠
3. **日志管理**：定期清理或轮转日志文件
4. **监控告警**：配置监控工具（如Prometheus + Grafana）
5. **备份策略**：定期备份数据库和配置文件

---

**快速开始命令**：

```bash
# 1. 给脚本添加执行权限
chmod +x start_ubuntu.sh

# 2. 启动服务
./start_ubuntu.sh start

# 3. 访问系统
# http://your-server-ip/
```

就这么简单！ 🎉
