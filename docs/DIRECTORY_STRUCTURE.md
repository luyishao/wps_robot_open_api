# WPS 机器人管理系统 - 目录结构说明

## 📁 项目目录结构

```
wps_robot_open_api/
│
├── README.md                          # 项目主说明文档
├── requirements.txt                   # Python依赖包列表
├── manage.py                          # Django管理脚本
├── .env.example                       # 环境变量示例文件
├── .gitignore                         # Git忽略文件配置
├── Dockerfile                         # Docker镜像构建文件
├── docker-compose.yml                 # Docker Compose配置
├── nginx.conf                         # Nginx配置文件
├── nginx_config_example.conf          # Nginx配置示例
│
├── shell/                             # 🆕 Shell脚本和批处理文件
│   ├── start.bat                      # Windows启动脚本
│   ├── 一键启动.bat                    # Windows一键启动（需Anaconda）
│   ├── init_and_run.bat               # 初始化并运行
│   ├── 启动服务器_venv.bat             # 虚拟环境启动
│   ├── 启动服务器_HTTPS_443.bat        # HTTPS模式启动
│   ├── docker-entrypoint.sh           # Docker入口脚本
│   ├── fix-docker-build.sh            # 修复Docker构建脚本
│   ├── fix-docker-build.bat           # 修复Docker构建（Windows）
│   ├── fix-line-endings.sh            # 修复行尾符
│   └── test-docker.sh                 # Docker测试脚本
│
├── docs/                              # 🆕 项目文档
│   ├── 快速开始.md                     # 快速入门指南
│   ├── 功能清单.md                     # 功能列表和说明
│   ├── 项目结构说明.md                 # 详细的项目结构
│   ├── WPS协作后台机器人Django项目需求.md  # 原始需求文档
│   ├── DEPLOYMENT_CHECKLIST.md        # 部署检查清单
│   ├── QUICK_TEST_GUIDE.md            # 快速测试指南
│   ├── DOCKER_DEPLOY.md               # Docker部署文档
│   ├── DOCKER_README.md               # Docker说明
│   ├── DOCKER_SUMMARY.md              # Docker总结
│   ├── CARD_USAGE.md                  # 卡片消息使用指南
│   ├── CARD_SIMPLE_GUIDE.md           # 卡片消息简明指南
│   ├── CARD_MESSAGE_TEST.md           # 卡片消息测试
│   ├── WEBHOOK_TEST_GUIDE.md          # Webhook测试指南
│   ├── WEBHOOK_RESPONSE_FORMAT.md     # Webhook响应格式
│   ├── WEBHOOK_CALLBACK_UPDATE.md     # Webhook回调更新说明
│   ├── WEBHOOK_GET_SUPPORT.md         # Webhook GET支持
│   ├── WEBHOOK_URL_FIX.md             # Webhook URL修复
│   ├── HOOK_SCRIPT_TROUBLESHOOTING.md # Hook脚本故障排除
│   ├── ROBOT_SAVE_FIX.md              # 机器人保存修复
│   ├── PASSWORD_SECURITY_CHECK.md     # 密码安全检查
│   ├── PYTHON_VERSION_CHANGE.md       # Python版本变更
│   ├── PYTHON_VERSION_UPGRADE.md      # Python版本升级
│   ├── FIX_DOCKER_BUILD_ERROR.md      # Docker构建错误修复
│   ├── FIX_DOCKER_COMPOSE.md          # Docker Compose修复
│   ├── FIX_LINE_ENDINGS.md            # 行尾符修复
│   ├── INSTALL_DOCKER_COMPOSE.md      # Docker Compose安装
│   └── UPDATE_LOG.md                  # 更新日志
│
├── tests/                             # 🆕 测试文件
│   ├── card_message_case.json         # 卡片消息测试用例
│   ├── card_only.json                 # 纯卡片测试
│   └── card_simple_test.json          # 简单卡片测试
│
├── wps_robot/                         # Django项目配置目录
│   ├── __init__.py
│   ├── settings.py                    # 项目设置
│   ├── urls.py                        # 主URL配置
│   ├── wsgi.py                        # WSGI配置
│   └── asgi.py                        # ASGI配置
│
├── robots/                            # 机器人应用目录
│   ├── models.py                      # 数据模型
│   ├── views.py                       # 视图函数
│   ├── urls.py                        # URL路由
│   ├── forms.py                       # 表单定义
│   ├── admin.py                       # 管理后台配置
│   ├── apps.py                        # 应用配置
│   ├── tests.py                       # 单元测试
│   │
│   ├── templates/                     # 模板文件
│   │   └── robots/
│   │       ├── base.html              # 基础模板
│   │       ├── login.html             # 登录页面
│   │       ├── dashboard.html         # 控制台首页
│   │       ├── robot_list.html        # 机器人列表
│   │       ├── robot_form.html        # 机器人表单
│   │       ├── robot_detail.html      # 机器人详情
│   │       ├── send_message.html      # 发送消息
│   │       ├── message_list.html      # 消息列表
│   │       └── ...                    # 其他模板
│   │
│   ├── templatetags/                  # 自定义模板标签
│   │   ├── __init__.py
│   │   └── json_filters.py            # JSON格式化过滤器
│   │
│   ├── hooks/                         # Hook脚本目录
│   │   ├── __init__.py
│   │   ├── example_hook.py            # 示例Hook
│   │   └── echo_hook.py               # 回显Hook
│   │
│   ├── management/                    # 管理命令
│   │   └── commands/
│   │       └── create_default_admin.py # 创建默认管理员
│   │
│   └── migrations/                    # 数据库迁移
│       └── ...
│
└── static/                            # 静态文件目录
    └── .gitkeep
```

## 📋 快速开始

查看 `docs/快速开始.md` 了解如何快速启动项目。

## 🔧 常用脚本

### Windows用户

- **一键启动**: `shell\一键启动.bat` （需要Anaconda环境）
- **简单启动**: `shell\start.bat`
- **初始化并运行**: `shell\init_and_run.bat`

### Linux/Mac用户

```bash
# 修复脚本权限
chmod +x shell/*.sh

# 启动服务器
python manage.py runserver
```

### Docker用户

```bash
# 构建并启动
docker-compose up -d
```

## 📚 文档导航

- **快速入门**: `docs/快速开始.md`
- **功能说明**: `docs/功能清单.md`
- **项目结构**: `docs/项目结构说明.md`
- **部署指南**: `docs/DEPLOYMENT_CHECKLIST.md`
- **Webhook测试**: `docs/WEBHOOK_TEST_GUIDE.md`
- **卡片消息**: `docs/CARD_USAGE.md`

## 🔄 目录结构变更说明

为了更好的组织项目文件，我们进行了以下调整：

1. **shell/** - 所有的 `.sh` 和 `.bat` 脚本文件
2. **docs/** - 所有的 `.md` 文档文件（除了README.md）
3. **tests/** - 测试相关的JSON文件

这样使项目根目录更加整洁，便于管理和维护。

## 🔔 重要变更通知

### Webhook URL格式变更 (v4.0 - 2026-01-30)
- **新格式**: `/at_robot/{username}/{robot_name}`
- **旧格式v3**: `/xz_robot/{username}/{robot_name}` (已废弃)
- **旧格式v2**: `/callback/{username}/{robot_name}` (已废弃)
- **详细说明**: 查看 [WEBHOOK_URL_CHANGE_V4.md](WEBHOOK_URL_CHANGE_V4.md)

---
