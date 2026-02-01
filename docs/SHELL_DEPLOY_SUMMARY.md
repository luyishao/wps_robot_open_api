# Shell部署脚本总结

本项目提供了三个Shell脚本用于Linux/Unix/MacOS系统的自动化部署和管理。

## 📦 脚本文件

| 脚本 | 功能 | 位置 |
|------|------|------|
| `start.sh` | 一键启动脚本 | 项目根目录 |
| `stop.sh` | 停止服务脚本 | 项目根目录 |
| `status.sh` | 状态检查脚本 | 项目根目录 |

## 🎯 核心功能

### start.sh - 一键启动脚本

**自动完成**：
- ✅ 环境检测（Python、Docker等）
- ✅ 依赖安装（requirements.txt）
- ✅ 数据库迁移和初始化
- ✅ 创建默认管理员账户
- ✅ 收集静态文件
- ✅ 启动服务

**支持模式**：
- 虚拟环境模式（默认）
- Docker模式

**使用示例**：
```bash
# 基本部署
./start.sh

# Docker部署
./start.sh --mode=docker

# 自定义端口
./start.sh --port=9000

# 清理后重新部署
./start.sh --clean
```

### stop.sh - 停止服务脚本

**功能**：
- 🛑 安全停止Django/Gunicorn进程
- 🛑 停止Docker容器
- 🧹 清理PID文件
- 🧹 可选清理日志文件

**使用示例**：
```bash
# 正常停止
./stop.sh

# 强制停止
./stop.sh --force

# 停止并清理日志
./stop.sh --clean
```

### status.sh - 状态检查脚本

**检查内容**：
- 📊 服务运行状态
- 📊 端口占用情况
- 📊 数据库状态
- 📊 系统资源使用
- 📊 环境配置
- 📊 服务连接测试

**使用示例**：
```bash
# 基本状态
./status.sh

# 详细状态
./status.sh --detailed

# 查看日志
./status.sh --logs

# 测试连接
./status.sh --test
```

## 🚀 快速上手

### 第一次部署

```bash
# 1. 添加执行权限
chmod +x start.sh stop.sh status.sh

# 2. 一键启动
./start.sh

# 3. 检查状态
./status.sh --test

# 4. 访问系统
# http://localhost:8080
# 用户名: admin / 密码: admin123456
```

### 日常管理

```bash
# 查看状态
./status.sh

# 查看详细信息和日志
./status.sh --detailed --logs

# 停止服务
./stop.sh

# 重启服务
./stop.sh && ./start.sh

# 更新部署
git pull
./stop.sh
./start.sh --clean
```

## 🐳 Docker部署流程

```bash
# 1. Docker部署
./start.sh --mode=docker

# 2. 查看容器状态
docker ps

# 3. 查看日志
docker-compose logs -f

# 4. 停止容器
./stop.sh
# 或
docker-compose down
```

## ⚙️ 高级选项

### start.sh选项

```bash
--mode=venv        # 虚拟环境模式（默认）
--mode=docker      # Docker模式
--port=8080        # 指定端口（默认8080）
--no-start         # 仅配置不启动
--clean            # 清理后重新部署
--help             # 显示帮助
```

### stop.sh选项

```bash
--force            # 强制停止（kill -9）
--clean            # 清理日志文件
--help             # 显示帮助
```

### status.sh选项

```bash
--detailed         # 显示详细信息
--logs             # 显示最近日志
--test             # 测试HTTP连接
--help             # 显示帮助
```

## 🔍 故障排查

### 问题：部署失败

```bash
# 查看详细错误
./start.sh 2>&1 | tee deploy.log

# 检查Python版本
python3 --version

# 手动安装依赖
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 问题：服务无法启动

```bash
# 检查端口占用
./status.sh

# 强制停止旧进程
./stop.sh --force

# 清理重新部署
./start.sh --clean
```

### 问题：无法连接服务

```bash
# 检查服务状态和测试连接
./status.sh --test

# 查看日志
./status.sh --logs

# 检查防火墙
sudo ufw status
```

## 📋 部署检查清单

- [ ] Python 3.11+ 已安装
- [ ] pip3 已安装
- [ ] 脚本有执行权限（chmod +x）
- [ ] 端口8080未被占用
- [ ] .env文件配置正确
- [ ] 服务启动成功
- [ ] HTTP测试通过
- [ ] 默认密码已修改

## 🔐 生产环境建议

1. **修改配置**
   ```bash
   # 编辑.env文件
   nano .env
   
   # 必须修改：
   # - SECRET_KEY
   # - DEBUG=False
   # - ALLOWED_HOSTS
   # - DEFAULT_ADMIN_PASSWORD
   ```

2. **使用Systemd服务**
   ```bash
   # 创建服务文件
   sudo nano /etc/systemd/system/wps-robot.service
   
   # 启用服务
   sudo systemctl enable wps-robot
   sudo systemctl start wps-robot
   ```

3. **配置Nginx**
   ```bash
   # 使用提供的配置文件
   sudo cp nginx_config_example.conf /etc/nginx/sites-available/wps_robot
   sudo ln -s /etc/nginx/sites-available/wps_robot /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

4. **定期备份**
   ```bash
   # 备份数据库
   cp db.sqlite3 backup/db.sqlite3.$(date +%Y%m%d)
   
   # 备份配置
   cp .env backup/.env.$(date +%Y%m%d)
   ```

## 📚 相关文档

- [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md) - 完整的Shell脚本文档
- [README.md](README.md) - 项目主文档
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速参考
- [docs/DOCKER_DEPLOY.md](docs/DOCKER_DEPLOY.md) - Docker部署指南

## 💡 提示

1. **首次使用**：建议先阅读 [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md)
2. **快速参考**：常用命令见 [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
3. **问题排查**：使用 `./status.sh --detailed --logs` 诊断
4. **更新部署**：先停止服务，再清理部署

---

**脚本版本**: 1.0.0  
**创建日期**: 2026-01-30  
**适用系统**: Linux, Unix, MacOS
