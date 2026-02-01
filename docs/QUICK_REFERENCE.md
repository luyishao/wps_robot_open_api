# 🚀 快速参考

## 🔧 快速启动

### Windows
```batch
# 一键启动（推荐）
shell\一键启动.bat

# 虚拟环境启动
shell\启动服务器_venv.bat
```

### Linux/MacOS
```bash
# 一键启动（推荐）
chmod +x start.sh && ./start.sh

# Docker部署
./start.sh --mode=docker

# 手动启动
python manage.py runserver 0.0.0.0:8080
```

---

## 🔐 默认访问信息

- **URL**: http://127.0.0.1:8080/
- **用户名**: admin
- **密码**: admin123456

⚠️ **首次登录后请立即修改密码！**

---

## 📡 Webhook URL 格式

```
旧格式v2: /callback/{username}/{robot_name}  ❌ 已废弃
旧格式v3: /xz_robot/{username}/{robot_name}  ❌ 已废弃
新格式v4: /at_robot/{username}/{robot_name}  ✅ 当前版本
```

**完整URL示例**:
```
http://your-domain.com:8080/at_robot/admin/myrobot
```

**支持的请求方法**:
- `GET`: WPS验证回调地址
- `POST`: 接收消息

---

## 💻 Shell脚本命令（Linux/MacOS）

```bash
# 部署
./start.sh                     # 虚拟环境部署
./start.sh --mode=docker       # Docker部署
./start.sh --port=9000         # 自定义端口
./start.sh --clean             # 清理后重新部署

# 停止
./stop.sh                      # 正常停止
./stop.sh --force              # 强制停止

# 状态
./status.sh                    # 基本状态
./status.sh --detailed         # 详细状态
./status.sh --logs             # 查看日志
./status.sh --test             # 测试连接
```

详细文档: [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md)

---

## 📝 消息类型

### 1. 文本消息
```json
{
  "msgtype": "text",
  "text": {
    "content": "消息内容"
  }
}
```

### 2. Markdown消息
```json
{
  "msgtype": "markdown",
  "markdown": {
    "text": "# 标题\n\n内容"
  }
}
```

### 3. 卡片消息
```json
{
  "msgtype": "card",
  "card": {
    "header": {
      "title": {
        "tag": "text",
        "content": {"type": "plainText", "text": "标题"}
      }
    },
    "elements": [
      {
        "tag": "text",
        "content": {"type": "plainText", "text": "内容"}
      }
    ]
  }
}
```

---

## 💻 常用Django命令

```bash
# 激活虚拟环境
.\venv\Scripts\activate        # Windows
source venv/bin/activate       # Linux/MacOS

# 数据库迁移
python manage.py makemigrations
python manage.py migrate

# 创建管理员
python manage.py create_default_admin

# 启动服务
python manage.py runserver 8080
```

---

## 🐳 Docker命令

```bash
# 构建并启动
docker-compose up -d --build

# 停止
docker-compose down

# 查看日志
docker-compose logs -f

# 重启
docker-compose restart
```

---

## 🔍 故障排查

### 端口被占用
```bash
# Windows
netstat -ano | findstr :8080
taskkill /F /PID <进程ID>

# Linux/MacOS
lsof -i :8080
kill $(lsof -ti :8080)
```

### 查看日志
```bash
# 服务器日志
tail -f server.log

# 查看错误
grep -i error server.log
```

---

## 📁 重要目录和文件

| 路径 | 说明 |
|------|------|
| `shell/` | Windows启动脚本 |
| `docs/` | 项目文档 |
| `tests/` | 测试用例 |
| `robots/hooks/` | 预设Hook脚本 |
| `media/hook_scripts/` | 上传的Hook脚本 |
| `.env` | 环境配置 |
| `db.sqlite3` | 数据库文件 |

---

## 📖 文档导航

### 入门文档
- [README.md](README.md) - 完整使用指南
- [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md) - Shell脚本详细文档
- [docs/快速开始.md](docs/快速开始.md) - 快速入门

### 功能文档
- [docs/功能清单.md](docs/功能清单.md) - 功能列表
- [docs/DIRECTORY_STRUCTURE.md](docs/DIRECTORY_STRUCTURE.md) - 目录结构
- [docs/CARD_USAGE.md](docs/CARD_USAGE.md) - 卡片消息使用

### 部署文档
- [docs/DOCKER_DEPLOY.md](docs/DOCKER_DEPLOY.md) - Docker部署指南
- [docs/DEPLOYMENT_CHECKLIST.md](docs/DEPLOYMENT_CHECKLIST.md) - 部署检查清单

### 更新日志
- [docs/UPDATE_LOG.md](docs/UPDATE_LOG.md) - 更新记录
- [docs/WEBHOOK_URL_CHANGE_V3.md](docs/WEBHOOK_URL_CHANGE_V3.md) - URL变更说明

---

## 🔄 迁移检查清单

- [ ] 更新WPS平台的webhook URL
- [ ] 测试GET请求验证
- [ ] 测试POST消息接收
- [ ] 验证消息记录功能
- [ ] 修改默认管理员密码
- [ ] 配置.env环境变量
- [ ] 设置ALLOWED_HOSTS

---

## 🎯 快速测试

```bash
# 测试Webhook（GET）
curl http://localhost:8080/at_robot/admin/test

# 测试Webhook（POST）
curl -X POST http://localhost:8080/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"test"}}'

# 查看服务状态（Linux/MacOS）
./status.sh --test
```

---

**版本**: v3.0 | **更新**: 2026-01-30
