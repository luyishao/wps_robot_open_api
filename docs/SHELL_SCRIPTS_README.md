# Shell脚本使用指南

本目录包含用于部署和管理WPS Robot Open API的Shell脚本。

## 🚀 快速开始

### Linux/Unix/MacOS系统

```bash
# 1. 给脚本添加执行权限
chmod +x start.sh stop.sh status.sh

# 2. 运行一键启动
./start.sh

# 3. 访问系统
# 浏览器打开: http://localhost:8080
# 用户名: admin
# 密码: admin123456
```

### Windows系统

请使用`shell/`目录下的批处理脚本：
- `shell/启动服务器_venv.bat` - 使用虚拟环境启动
- `shell/一键启动.bat` - Anaconda环境一键启动

## 📋 脚本说明

### 1. start.sh - 一键启动脚本

全自动部署启动脚本，支持虚拟环境和Docker两种部署方式。

#### 基本使用

```bash
# 默认部署（虚拟环境模式 + 8080端口）
./start.sh

# 使用Docker部署
./start.sh --mode=docker

# 自定义端口
./start.sh --port=9000

# 清理旧环境后重新部署
./start.sh --clean

# 仅配置不启动服务
./start.sh --no-start
```

#### 完整选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `--mode=venv` | 使用Python虚拟环境部署 | venv |
| `--mode=docker` | 使用Docker部署 | - |
| `--port=8080` | 指定HTTP端口 | 8080 |
| `--no-start` | 仅安装配置，不启动服务 | false |
| `--clean` | 清理旧环境后重新部署 | false |
| `--help` | 显示帮助信息 | - |

#### 脚本功能

1. **环境检测**
   - 检查Python版本（需要3.11+）
   - 检查pip、Docker等依赖工具
   - 验证系统兼容性

2. **自动配置**
   - 创建`.env`环境配置文件
   - 生成安全的SECRET_KEY
   - 配置ALLOWED_HOSTS

3. **依赖安装**
   - 创建Python虚拟环境
   - 安装requirements.txt中的依赖
   - 安装Gunicorn（虚拟环境模式）

4. **数据库初始化**
   - 执行数据库迁移
   - 创建默认管理员账户
   - 收集静态文件

5. **服务启动**
   - 虚拟环境模式：启动Django开发服务器
   - Docker模式：启动Docker容器

#### 部署示例

**场景1：开发环境快速部署**
```bash
# 使用默认配置
./start.sh
```

**场景2：生产环境Docker部署**
```bash
# 使用Docker，清理旧环境
./start.sh --mode=docker --clean
```

**场景3：自定义端口部署**
```bash
# 使用9000端口
./start.sh --port=9000
```

**场景4：仅准备环境不启动**
```bash
# 准备好环境，手动启动
./start.sh --no-start

# 手动启动
source venv/bin/activate
python manage.py runserver 0.0.0.0:8080
```

---

### 2. stop.sh - 停止服务脚本

安全停止WPS Robot服务，支持虚拟环境和Docker模式。

#### 基本使用

```bash
# 正常停止服务
./stop.sh

# 强制停止所有进程
./stop.sh --force

# 停止服务并清理日志
./stop.sh --clean
```

#### 选项说明

| 选项 | 说明 |
|------|------|
| `--force` | 强制停止所有相关进程（使用kill -9） |
| `--clean` | 停止服务并删除日志文件 |
| `--help` | 显示帮助信息 |

#### 脚本功能

1. **进程管理**
   - 停止Django开发服务器
   - 停止Gunicorn进程
   - 停止Docker容器

2. **清理功能**
   - 删除PID文件
   - 清理日志文件（可选）
   - 显示最终状态

3. **安全停止**
   - 优先使用SIGTERM信号
   - 等待进程正常退出
   - 超时后强制停止（--force）

#### 使用场景

**场景1：正常停止服务**
```bash
./stop.sh
```

**场景2：进程卡住无法停止**
```bash
# 强制停止
./stop.sh --force
```

**场景3：清理重启**
```bash
# 停止并清理日志
./stop.sh --clean

# 重新启动
./start.sh
```

---

### 3. status.sh - 状态检查脚本

查看服务运行状态、系统资源、日志信息等。

#### 基本使用

```bash
# 查看基本状态
./status.sh

# 查看详细状态
./status.sh --detailed

# 查看状态和最近日志
./status.sh --logs

# 测试服务连接
./status.sh --test

# 组合使用
./status.sh --detailed --logs --test
```

#### 选项说明

| 选项 | 说明 |
|------|------|
| `--detailed` | 显示详细信息（CPU、内存、进程等） |
| `--logs` | 显示最近的日志（最后20行） |
| `--test` | 测试HTTP服务连接 |
| `--help` | 显示帮助信息 |

#### 检查内容

1. **服务状态**
   - Django开发服务器状态
   - Gunicorn进程状态
   - Docker容器状态
   - 进程PID和运行时间

2. **端口占用**
   - 8080, 8000, 443, 80端口状态
   - 占用进程信息

3. **数据库状态**
   - db.sqlite3文件大小
   - 修改时间
   - 数据表统计（详细模式）

4. **环境配置**
   - .env文件检查
   - Python虚拟环境检查
   - 配置项显示（隐藏敏感信息）

5. **系统资源**（详细模式）
   - 内存使用情况
   - 磁盘使用情况
   - CPU负载

6. **连接测试**（--test）
   - HTTP服务响应测试
   - 登录页面可访问性
   - 响应状态码

7. **日志查看**（--logs）
   - server.log
   - nohup.out
   - Docker容器日志

#### 使用场景

**场景1：快速检查服务是否运行**
```bash
./status.sh
```

**场景2：排查性能问题**
```bash
# 查看详细的资源使用情况
./status.sh --detailed
```

**场景3：调试连接问题**
```bash
# 测试HTTP连接是否正常
./status.sh --test
```

**场景4：查看错误日志**
```bash
# 查看最近的日志输出
./status.sh --logs
```

**场景5：全面诊断**
```bash
# 查看所有信息
./status.sh --detailed --logs --test
```

---

## 🔄 完整部署流程

### 开发环境部署

```bash
# 1. 克隆或下载项目
cd wps_robot_open_api

# 2. 添加执行权限
chmod +x start.sh stop.sh status.sh

# 3. 一键启动
./start.sh

# 4. 检查状态
./status.sh

# 5. 访问系统
# http://localhost:8080
# 用户名: admin
# 密码: admin123456
```

### 生产环境部署（Docker）

```bash
# 1. 准备环境
cd wps_robot_open_api

# 2. 配置环境变量
cp .env.example .env
nano .env  # 修改配置

# 3. Docker部署
chmod +x start.sh
./start.sh --mode=docker

# 4. 检查状态
./status.sh --detailed --test

# 5. 查看日志
./status.sh --logs
```

### 更新部署

```bash
# 1. 停止服务
./stop.sh

# 2. 拉取最新代码
git pull

# 3. 清理重新部署
./start.sh --clean

# 4. 检查状态
./status.sh --test
```

---

## 🛠️ 故障排查

### 问题1：部署失败

```bash
# 查看详细错误信息
./start.sh 2>&1 | tee deploy.log

# 检查环境
python3 --version
pip3 --version

# 手动安装依赖
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 问题2：服务无法启动

```bash
# 检查端口占用
./status.sh

# 查看日志
./status.sh --logs

# 强制停止旧进程
./stop.sh --force

# 重新启动
./start.sh --clean
```

### 问题3：服务运行异常

```bash
# 查看详细状态
./status.sh --detailed --logs --test

# 检查数据库
sqlite3 db.sqlite3 ".tables"

# 重新初始化数据库
./stop.sh
rm db.sqlite3
./start.sh
```

### 问题4：端口被占用

```bash
# 查看端口占用
lsof -i :8080

# 停止占用进程
kill $(lsof -ti :8080)

# 或使用不同端口
./start.sh --port=9000
```

### 问题5：Docker部署失败

```bash
# 查看Docker状态
docker ps -a
docker logs <container_id>

# 清理重建
./stop.sh
docker-compose down -v
./start.sh --mode=docker --clean
```

---

## 📝 日志文件

| 文件 | 说明 | 位置 |
|------|------|------|
| server.log | Django服务日志 | 项目根目录 |
| nohup.out | 后台运行输出 | 项目根目录 |
| server.pid | 服务进程PID | 项目根目录 |
| db.sqlite3 | 数据库文件 | 项目根目录 |
| .env | 环境配置 | 项目根目录 |

**查看日志命令**：
```bash
# 实时查看
tail -f server.log

# 查看最后100行
tail -n 100 server.log

# 搜索错误
grep -i error server.log
```

---

## ⚙️ 高级配置

### 自定义环境变量

编辑`.env`文件：
```bash
nano .env
```

重要配置项：
```bash
# 密钥（生产环境必须修改）
SECRET_KEY=your-secret-key-here

# 调试模式（生产环境设为False）
DEBUG=False

# 允许的主机
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

# 管理员账号
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_PASSWORD=your-secure-password
```

### 使用Nginx反向代理

```bash
# 1. 安装Nginx
sudo apt install nginx

# 2. 复制配置文件
sudo cp nginx_config_example.conf /etc/nginx/sites-available/wps_robot
sudo ln -s /etc/nginx/sites-available/wps_robot /etc/nginx/sites-enabled/

# 3. 测试配置
sudo nginx -t

# 4. 启动服务
./start.sh
sudo systemctl restart nginx
```

### 开机自启动（systemd）

创建服务文件：
```bash
sudo nano /etc/systemd/system/wps-robot.service
```

内容：
```ini
[Unit]
Description=WPS Robot Open API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/wps_robot_open_api
ExecStart=/path/to/wps_robot_open_api/venv/bin/gunicorn --bind 0.0.0.0:8080 wps_robot.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
```

启用服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable wps-robot
sudo systemctl start wps-robot
```

---

## 🔒 安全建议

1. **修改默认密码**
   - 首次登录后立即修改admin密码

2. **保护敏感文件**
   ```bash
   chmod 600 .env
   chmod 600 db.sqlite3
   ```

3. **使用HTTPS**
   - 生产环境配置SSL证书
   - 使用Nginx做SSL终止

4. **限制文件上传**
   - Hook脚本来源可信
   - 定期审查上传的脚本

5. **备份数据**
   ```bash
   # 定期备份数据库
   cp db.sqlite3 backup/db.sqlite3.$(date +%Y%m%d)
   ```

---

## 📞 获取帮助

- 查看README: `cat README.md`
- 查看文档: `ls docs/`
- 脚本帮助: `./start.sh --help`
- 检查状态: `./status.sh --detailed --logs`

---

**版本**: 1.0.0  
**更新日期**: 2026-01-30  
**作者**: WPS Robot Team
