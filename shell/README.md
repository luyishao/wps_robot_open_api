# Shell 脚本说明

本目录包含项目的所有启动脚本和Shell工具。

## Windows 批处理文件 (.bat)

### 启动脚本
- **一键启动.bat** - 一键启动（需要Anaconda环境）
  - 自动检查Anaconda环境
  - 自动配置wps_robot环境
  - 自动启动服务器

- **start.bat** - 简单启动脚本
  - 直接启动Django服务器（8080端口）
  - 适合已配置好环境的情况

- **init_and_run.bat** - 初始化并运行
  - 安装依赖
  - 执行数据库迁移
  - 创建默认管理员
  - 启动服务器

- **启动服务器_venv.bat** - 虚拟环境启动
  - 激活虚拟环境
  - 启动HTTP服务（8080端口）

- **启动服务器_HTTPS_443.bat** - HTTPS启动
  - 需要先配置SSL证书
  - 启动HTTPS服务（443端口）

### Docker相关
- **fix-docker-build.bat** - 修复Docker构建问题（Windows）
  - 修复行尾符问题
  - 重建Docker镜像

## Linux/Mac Shell 脚本 (.sh)

### Docker相关
- **docker-entrypoint.sh** - Docker容器入口脚本
  - 容器启动时自动执行
  - 初始化数据库
  - 创建管理员账号
  - 启动Gunicorn服务器

- **fix-docker-build.sh** - 修复Docker构建问题
  - 转换文件行尾符为Unix格式
  - 重建Docker镜像

- **fix-line-endings.sh** - 修复文件行尾符
  - 将CRLF转换为LF
  - 解决跨平台兼容性问题

- **test-docker.sh** - Docker测试脚本
  - 测试Docker构建
  - 测试容器运行

## 使用方法

### Windows用户
```batch
# 方法1：一键启动（推荐，需Anaconda）
一键启动.bat

# 方法2：简单启动
start.bat

# 方法3：完整初始化
init_and_run.bat
```

### Linux/Mac用户
```bash
# 赋予脚本执行权限
chmod +x *.sh

# 运行脚本
./script_name.sh

# 或使用Python直接启动
python ../manage.py runserver 0.0.0.0:8080
```

### Docker用户
```bash
# 使用docker-compose（推荐）
docker-compose up -d

# 手动构建
docker build -t wps-robot .
docker run -p 8080:8080 wps-robot
```

## 注意事项

1. **Windows脚本**
   - 需要管理员权限的脚本会自动提示
   - HTTPS脚本需要先配置SSL证书
   - 一键启动需要Anaconda环境

2. **Linux/Mac脚本**
   - 首次运行需要添加执行权限
   - docker-entrypoint.sh由Docker自动调用
   - 注意文件行尾符格式（LF）

3. **Docker脚本**
   - 确保Docker和Docker Compose已安装
   - 检查端口8080是否被占用
   - 首次启动会较慢（需要构建镜像）

## 故障排查

### 脚本无法执行
```bash
# Linux/Mac: 添加执行权限
chmod +x script_name.sh

# Windows: 以管理员身份运行
右键 → 以管理员身份运行
```

### 端口被占用
```bash
# Windows
netstat -ano | findstr :8080
taskkill /F /PID <进程ID>

# Linux/Mac
lsof -i :8080
kill -9 <进程ID>
```

### Docker构建失败
```bash
# 清理Docker缓存
docker system prune -a

# 重新构建
docker-compose up -d --build
```
