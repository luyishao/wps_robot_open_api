# WPS Hook 机器人管理系统 - 使用指南

## 📌 项目简介

WPS协作后台机器人管理系统，支持接收和发送WPS机器人webhook消息，提供Web控制台管理界面。

## ✨ 主要功能

### 基础功能
- ✅ 用户登录认证
- ✅ 多用户、多机器人管理
- ✅ 接收webhook回调消息
- ✅ 发送消息到WPS机器人
- ✅ 消息记录查询

### 消息类型支持
- 📝 文本消息
- 📄 Markdown消息
- 🎴 卡片消息（新增）

### Hook脚本功能
- 📁 支持预设hook脚本
- ⬆️ **支持上传Python脚本文件**（新增）
- 🔄 自动处理接收到的消息

### 消息管理
- 💾 **智能消息记录清理**
- 📊 每个机器人可设置最大消息保存数量（默认100条，最大1000条）
- 🗑️ 自动删除超出限制的旧消息

### 端口配置
- 🌐 HTTP服务：80端口
- 🔒 HTTPS服务：443端口（需配置SSL证书）

## 🚀 快速启动

### 📂 项目目录结构

项目文件已按类型整理到不同目录：
- **shell/** - 所有启动脚本和Shell文件
- **docs/** - 所有文档文件
- **tests/** - 测试文件和示例

详细结构请查看：[docs/DIRECTORY_STRUCTURE.md](docs/DIRECTORY_STRUCTURE.md)

---

### 方法一：Windows启动 🪟

**使用Waitress（推荐）**：
```bash
.\start_waitress.bat
```

访问地址：http://localhost/

---

### 方法二：Ubuntu后台运行 🐧

**快速启动**（推荐）：
```bash
# 给脚本添加执行权限
chmod +x start_ubuntu.sh

# 使用nohup启动（默认）
./start_ubuntu.sh start

# 或使用screen启动
./start_ubuntu.sh start screen

# 或使用systemd启动
./start_ubuntu.sh start systemd

# 查看状态
./start_ubuntu.sh status

# 查看日志
./start_ubuntu.sh logs

# 停止服务
./start_ubuntu.sh stop
```

详细部署指南：[docs/UBUNTU_BACKGROUND_DEPLOY.md](docs/UBUNTU_BACKGROUND_DEPLOY.md)

---

### 方法三：使用Shell脚本（Linux/Unix/MacOS）

**一键启动**：
```bash
# 1. 添加执行权限
chmod +x start.sh stop.sh status.sh

# 2. 运行一键启动
./start.sh

# 3. 检查服务状态
./status.sh

# 4. 访问系统
# http://localhost:80
# 用户名: admin
# 密码: admin123456
```

**Docker部署**：
```bash
./start.sh --mode=docker
```

**详细文档**：
- 📘 [Shell脚本使用指南](docs/SHELL_SCRIPTS_README.md) - **推荐阅读**
- 📗 包含部署、停止、状态检查的完整说明

---

### 方法二：Docker部署（推荐用于生产环境）⭐

**一键启动**：
```bash
docker-compose up -d --build
```

**访问系统**：
- URL: `http://your-server:80`
- 用户名: `admin`
- 密码: `admin123456`

**详细文档**：
- 📘 [Docker快速部署指南](docs/DOCKER_README.md)
- 📗 [Docker完整部署文档](docs/DOCKER_DEPLOY.md)
- 📋 [部署检查清单](docs/DEPLOYMENT_CHECKLIST.md)

---

### 方法三：使用批处理脚本（Windows开发环境）

1. **启动HTTP服务（80端口）**
   ```bash
   双击运行：shell/启动服务器_venv.bat
   ```

2. **一键启动（需Anaconda环境）**
   ```bash
   双击运行：shell/一键启动.bat
   ```

3. **启动HTTPS服务（443端口）**
   ```bash
   # 需要先配置SSL证书
   双击运行：shell/启动服务器_HTTPS_443.bat
   ```

---

### 方法四：手动启动（开发环境）

```bash
# 激活虚拟环境
.\venv\Scripts\activate

# 启动HTTP服务（80端口）
python manage.py runserver 80

# 或启动默认端口（8000）
python manage.py runserver
```

### 方法五：使用Nginx反向代理（生产环境推荐）

参考 `nginx_config_example.conf` 配置文件

## 🔐 访问信息

- **HTTP访问地址**: http://127.0.0.1:80/
- **默认用户名**: `admin`
- **默认密码**: `admin123456`

## 📝 功能详解

### 1. Hook脚本上传

支持两种方式配置Hook脚本：

#### 方式一：上传Python脚本文件
1. 在机器人配置页面，点击"浏览"选择.py文件
2. 上传的脚本必须包含`process_message(robot, message_data)`函数
3. 文件大小限制：1MB
4. **优先级高于预设脚本**

#### 方式二：使用预设脚本
1. 将脚本文件放在 `robots/hooks/` 目录
2. 在机器人配置中填写脚本名称（不含.py）
3. 例如：`example_hook`

**脚本示例**：
```python
def process_message(robot, message_data):
    """
    处理webhook消息
    
    参数:
        robot: 机器人对象
        message_data: webhook接收的数据
    
    返回:
        dict: 要返回给WPS的响应数据（可选）
    """
    msg_type = message_data.get('msgtype', '')
    
    if msg_type == 'text':
        text = message_data.get('text', {}).get('content', '')
        return {
            'msgtype': 'text',
            'text': {
                'content': f'已收到：{text}'
            }
        }
    
    return None
```

### 2. 消息数量限制

每个机器人可以单独设置消息保存数量：

- **默认值**: 100条
- **范围**: 1-1000条
- **清理时机**: 
  - 接收新消息时自动清理
  - 发送消息时自动清理
- **清理规则**: 保留最新的N条消息，删除旧消息

**配置方法**：
1. 编辑机器人
2. 设置"最大消息记录数"字段
3. 保存即可生效

### 3. 发送卡片消息

支持两种方式发送卡片消息：

#### 方式一：使用JSON格式（推荐）

**重要**：只需输入card部分的JSON，系统会自动添加`msgtype`字段。

在消息内容中输入card的JSON：
```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "标题"
      }
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "内容"
      }
    }
  ]
}
```

**测试文件**：
- `tests/card_simple_test.json` - 简单测试用例
- `tests/card_only.json` - 完整测试用例（带国际化）

**系统自动构造为**：
```json
{
  "msgtype": "card",
  "card": {你输入的JSON}
}
```

#### 方式二：使用表单字段
1. 选择消息类型：卡片消息
2. 填写卡片标题
3. 填写卡片内容

系统会自动构造为WPS标准格式。

### 4. 端口配置

#### 开发环境
- 使用Django自带服务器
- HTTP: 80端口
- 直接运行启动脚本即可

#### 生产环境（推荐）
- 使用Nginx作为反向代理
- HTTP: 80端口 → 转发到Django
- HTTPS: 443端口 → SSL终止后转发到Django
- 参考 `nginx_config_example.conf`

## 📁 项目结构

```
wps_robot_open_api/
├── README.md                      # 项目说明
├── manage.py                      # Django管理脚本
├── requirements.txt               # 项目依赖
├── db.sqlite3                     # 数据库文件
│
├── shell/                         # 🆕 启动脚本目录
│   ├── 一键启动.bat              # Windows一键启动
│   ├── start.bat                 # Windows启动脚本
│   ├── 启动服务器_venv.bat      # 虚拟环境启动
│   ├── 启动服务器_HTTPS_443.bat # HTTPS启动
│   └── ...其他shell脚本
│
├── docs/                         # 🆕 文档目录
│   ├── 快速开始.md
│   ├── 功能清单.md
│   ├── 项目结构说明.md
│   ├── DIRECTORY_STRUCTURE.md    # 目录结构说明
│   └── ...其他文档
│
├── tests/                        # 🆕 测试文件目录
│   ├── card_message_case.json
│   ├── card_only.json
│   └── card_simple_test.json
│
├── media/                        # 用户上传文件
│   └── hook_scripts/            # Hook脚本上传目录
│
├── wps_robot/                    # 项目配置
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
│
└── robots/                       # 机器人应用
    ├── models.py                # 数据模型
    ├── views.py                 # 视图逻辑
    ├── forms.py                 # 表单
    ├── hooks/                   # 预设Hook脚本目录
    │   ├── echo_hook.py
    │   └── example_hook.py
    └── templates/               # 模板文件
```

更多详情请查看：[docs/DIRECTORY_STRUCTURE.md](docs/DIRECTORY_STRUCTURE.md)

## 🔄 数据库迁移

如果是从旧版本升级，需要执行数据库迁移：

```bash
# 激活虚拟环境
.\venv\Scripts\activate

# 创建迁移
python manage.py makemigrations

# 应用迁移
python manage.py migrate
```

## 📊 API接口

### Webhook回调地址格式
```
GET/POST /at_robot/{username}/{robot_name}
```

**重要变更** (v4.0):
- 新格式: `/at_robot/` 前缀 + 用户名 + 机器人名
- 旧格式v3 `/xz_robot/{username}/{robot_name}` 已废弃
- 旧格式v2 `/callback/{username}/{robot_name}` 已废弃

例如：
- 用户名: `admin`
- 机器人名: `myrobot`
- 回调地址: `http://yourdomain:80/at_robot/admin/myrobot`

**支持的请求方法**:
- **GET**: WPS验证回调地址，返回 `{"result":"ok"}`
- **POST**: 接收实际消息，默认返回 `{"result":"ok"}`（hook脚本可自定义响应）

**特点**:
- ✅ 无需登录验证
- ✅ 无需CSRF令牌
- ✅ 支持GET和POST请求
- ✅ 自动记录所有请求

### 消息格式

#### 文本消息
```json
{
  "msgtype": "text",
  "text": {
    "content": "消息内容"
  }
}
```

#### Markdown消息
```json
{
  "msgtype": "markdown",
  "markdown": {
    "text": "# 标题\n\n内容"
  }
}
```

#### 卡片消息
```json
{
  "msgtype": "card",
  "card": {
    "title": "卡片标题",
    "text": "卡片内容"
  }
}
```

## ⚠️ 注意事项

1. **Hook脚本安全**
   - 上传的脚本会在服务器执行，请确保来源可信
   - 建议在隔离环境中测试脚本
   - 脚本错误会被捕获并记录到消息日志

2. **消息记录清理**
   - 自动清理是不可逆的
   - 建议根据实际需求设置合理的保存数量
   - 重要消息建议及时备份

3. **端口配置**
   - 80端口：HTTP，适合开发和内网使用
   - 443端口：HTTPS，生产环境建议使用Nginx
   - 修改端口可能需要管理员权限

4. **文件上传限制**
   - Hook脚本文件：最大1MB
   - 只接受.py格式文件
   - 上传的文件存储在media/hook_scripts/目录

## 🛠️ 技术栈

- **框架**: Django 4.2.9
- **Python**: 3.11+
- **数据库**: SQLite3
- **前端**: Bootstrap 5 + Bootstrap Icons

## 📖 参考文档

- [WPS开放平台 - Webhook机器人文档](https://365.kdocs.cn/3rd/open/documents/app-integration-dev/guide/robot/webhook)
- [Django官方文档](https://docs.djangoproject.com/)

## 🐛 问题排查

### ⚠️ 重要：Webhook 400错误

如果收到 `Bad request syntax ('10c')` 或 `('10a')` 错误，这是因为：
- WPS使用了HTTP分块传输编码
- Django开发服务器(`runserver`)不完全支持此特性

**解决方案**：使用生产级WSGI服务器

```bash
# Windows - 使用Waitress（推荐）
pip install waitress
waitress-serve --host=0.0.0.0 --port=80 --threads=4 wps_robot.wsgi:application

# 或使用启动脚本
.\start_waitress.bat

# Linux - 使用Gunicorn
pip install gunicorn
gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application
```

详细说明：[docs/FIX_400_CHUNKED_ENCODING.md](docs/FIX_400_CHUNKED_ENCODING.md)

### 查看日志

**方法1：Web日志查看器（推荐）** ⭐
```
访问: http://localhost:80/logs/
或点击左侧菜单"系统日志"
```

**特性**:
- 实时查看日志（Django/错误/Webhook）
- 自动刷新功能
- 一键下载所有日志（ZIP）
- 清理旧日志
- 深色主题，护眼舒适

详细说明：[docs/WEB_LOGS_FEATURE.md](docs/WEB_LOGS_FEATURE.md)

**方法2：命令行工具**

**Windows**:
```batch
# 查看所有日志
.\view_logs.bat

# 快速诊断400错误
.\diagnose_400.bat
```

**Linux/MacOS**:
```bash
# 查看日志
./logs.sh

# 查看错误日志
./logs.sh --view-error

# 查看Webhook日志
./logs.sh --view-webhook

# 实时跟踪
./logs.sh --follow
```

详细日志使用说明：[docs/LOGS_GUIDE.md](docs/LOGS_GUIDE.md)

### 1. 端口被占用
```bash
# Windows查看端口占用
netstat -ano | findstr :80

# 结束进程
taskkill /F /PID <进程ID>
```

### 2. 查看详细日志
- 检查脚本语法是否正确
- 查看消息日志中的错误信息
- 确保脚本包含process_message函数

### 3. 消息发送失败
- 检查Webhook URL是否正确
- 查看错误信息中的HTTP状态码
- 确认消息格式符合WPS要求

## 📞 技术支持

如有问题，请查看：
1. 服务器日志
2. 消息记录中的错误信息
3. Django调试输出

---

**版本**: v2.0
**更新日期**: 2026-01-30
