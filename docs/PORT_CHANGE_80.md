# 端口修改说明 - 改为80端口

## 📋 修改内容

已将默认HTTP端口从 **8080** 修改为 **80**

## 📝 修改的文件

### 1. 启动脚本配置
**文件**: `start.sh`
- 默认端口：`HTTP_PORT=80`
- 命令行参数说明已更新

### 2. Docker配置
**文件**: `docker-compose.yml`
- 端口映射：`"80:80"`
- Gunicorn绑定：`0.0.0.0:80`
- 健康检查：`localhost:80`

### 3. Nginx配置
**文件**: `nginx.conf`
- 上游服务器：`server web:80`

### 4. 文档更新
**文件**: `README.md`
- 所有端口说明已更新为80
- 访问地址已更新
- 示例命令已更新

## 🚀 使用方法

### 方法1：使用启动脚本（推荐）
```bash
# 使用默认端口80启动
./start.sh

# 或指定其他端口
./start.sh --port=8080
```

### 方法2：Docker部署
```bash
# Docker会自动使用80端口
docker-compose up -d --build
```

### 方法3：手动启动
```bash
# 使用Django开发服务器
python manage.py runserver 0.0.0.0:80
```

## 🔐 访问地址

- **HTTP**: http://localhost:80 或 http://localhost
- **默认账号**: admin
- **默认密码**: admin123456

## ⚠️ 重要提示

### 1. 权限要求
在Windows和Linux系统上，监听80端口通常需要**管理员/root权限**：

**Windows**:
```powershell
# 以管理员身份运行PowerShell或CMD
python manage.py runserver 0.0.0.0:80
```

**Linux**:
```bash
# 使用sudo运行
sudo python manage.py runserver 0.0.0.0:80

# 或使用非特权端口（推荐）
python manage.py runserver 0.0.0.0:8080
```

### 2. 端口冲突
80端口常被以下服务占用：
- IIS (Windows)
- Apache
- Nginx
- 其他Web服务器

**检查端口占用**:
```powershell
# Windows
netstat -ano | findstr :80

# Linux
sudo netstat -tulpn | grep :80
```

**停止冲突服务**:
```powershell
# Windows - 停止IIS
iisreset /stop

# 或停止特定进程
taskkill /F /PID <进程ID>
```

### 3. 生产环境建议

**不推荐**: 直接使用Django开发服务器监听80端口

**推荐方案**:
1. 使用Nginx反向代理（参考`nginx.conf`）
2. Django监听内部端口（如8080）
3. Nginx监听80/443端口并转发请求

**优势**:
- ✅ 更好的性能
- ✅ 更高的安全性
- ✅ 支持HTTPS
- ✅ 静态文件高效处理
- ✅ 负载均衡

## 📊 端口映射关系

### 开发环境
```
浏览器 → http://localhost:80 → Django开发服务器
```

### Docker环境
```
浏览器 → http://localhost:80 → Docker容器:80 → Gunicorn
```

### 生产环境（带Nginx）
```
浏览器 → http://localhost:80 → Nginx:80 → Django:8080
浏览器 → https://localhost:443 → Nginx:443 → Django:8080
```

## 🔄 回退到8080端口

如果需要改回8080端口，修改以下文件：

1. **start.sh**: `HTTP_PORT=8080`
2. **docker-compose.yml**: `"8080:8080"` 和 `0.0.0.0:8080`
3. **nginx.conf**: `server web:8080`

或直接运行：
```bash
./start.sh --port=8080
```

## 📅 修改日期

2026-01-30

## 📌 相关文档

- [README.md](../README.md) - 主文档
- [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md) - Shell脚本说明
- [docker-compose.yml](docker-compose.yml) - Docker配置
- [nginx.conf](nginx.conf) - Nginx配置
