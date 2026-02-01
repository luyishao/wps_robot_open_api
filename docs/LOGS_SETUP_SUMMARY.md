# 日志系统配置完成总结

## ✅ 已完成的配置

### 1. Django日志系统配置
**文件**: `wps_robot/settings.py`

已添加完整的日志配置：
- Django主日志：`logs/django.log`
- 错误日志：`logs/error.log`
- Webhook专用日志：`logs/webhook.log`
- 自动日志轮转（10MB，保留5-10个备份）

### 2. 日志查看工具

**Windows工具**:
- `view_logs.bat` - 图形化日志查看工具
- `diagnose_400.bat` - 400错误快速诊断工具

**Linux/MacOS工具**:
- `logs.sh` - 完整的日志管理脚本
  - 查看日志
  - 导出日志
  - 清理日志
  - 分析错误

### 3. 文档
- `LOGS_GUIDE.md` - 详细的日志使用指南
- `logs/README.md` - 日志目录说明

### 4. 配置更新
- `.gitignore` - 已添加日志目录排除
- `README.md` - 已添加日志相关说明

---

## 🚀 快速使用

### 查看日志（Windows）
```batch
# 方法1：使用图形化工具（推荐）
.\view_logs.bat

# 方法2：直接查看文件
notepad logs\django.log
notepad logs\error.log
notepad logs\webhook.log

# 方法3：使用PowerShell
Get-Content logs\django.log -Tail 100 -Encoding UTF8
```

### 查看日志（Linux/MacOS）
```bash
# 方法1：使用脚本（推荐）
./logs.sh                    # 查看Django日志
./logs.sh --view-error       # 查看错误日志
./logs.sh --view-webhook     # 查看Webhook日志
./logs.sh --follow           # 实时跟踪

# 方法2：直接查看文件
tail -n 100 logs/django.log
tail -f logs/webhook.log
```

### 导出日志
```bash
# Windows
.\view_logs.bat
# 选择 [4] 导出所有日志

# Linux
./logs.sh --export
```

### 诊断400错误（Windows）
```batch
.\diagnose_400.bat
```

---

## 🔍 针对你的400错误

### 问题分析
```
[30/Jan/2026 18:13:18] "POST /at_robot/admin/test HTTP/1.1" 400 25
[30/Jan/2026 18:13:18] code 400, message Bad request syntax ('10a')
[30/Jan/2026 18:13:18] "10a" 400 -
```

这个错误表示：
- HTTP请求格式错误
- `'10a'` 不是有效的HTTP请求行
- 可能是WPS发送的数据格式有问题

### 排查步骤

#### 步骤1：启用DEBUG模式
编辑 `.env` 文件：
```
DEBUG=True
```

重启服务：
```bash
# Windows
taskkill /F /IM python.exe
python manage.py runserver 0.0.0.0:80

# Linux
./stop.sh
./start.sh
```

#### 步骤2：查看详细日志
```bash
# Windows
.\view_logs.bat
# 选择 [3] 查看Webhook日志

# Linux
./logs.sh --view-webhook --follow
```

#### 步骤3：测试连接
```bash
# 测试GET请求
curl http://localhost:80/at_robot/admin/test

# 测试POST请求
curl -X POST http://localhost:80/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试"}}'
```

#### 步骤4：检查WPS配置
1. 登录WPS管理后台
2. 检查机器人Webhook URL是否正确
3. 确认格式：`http://your-server:80/at_robot/admin/test`
4. 测试WPS是否能访问你的服务器

#### 步骤5：查看数据库记录
登录系统后台：http://localhost:80
- 查看"消息记录"
- 查看是否有收到的请求数据
- 检查data字段中的原始数据

---

## 📊 日志文件说明

### logs/django.log
- 记录所有INFO及以上级别的日志
- 包括请求、响应、数据库操作等
- 适合查看系统整体运行情况

### logs/error.log
- 仅记录ERROR级别的日志
- 包含详细的错误堆栈
- 适合快速定位问题

### logs/webhook.log
- 专门记录webhook相关的日志
- 包含请求头、请求体、响应等详细信息
- 最适合排查webhook问题

---

## 💡 常见问题

### Q: 日志文件不存在？
A: 服务还未启动或未接收到请求。启动服务后发送测试请求即可生成日志。

### Q: 日志太大怎么办？
A: 系统会自动轮转，单个文件超过10MB会自动创建新文件。也可以手动清理30天前的日志：
```bash
./logs.sh --clean
```

### Q: 如何搜索特定错误？
A: 
```powershell
# Windows
Select-String -Path "logs\*.log" -Pattern "400"

# Linux
grep -r "400" logs/
```

### Q: 日志包含中文乱码？
A: 使用UTF-8编码查看：
```powershell
# Windows PowerShell
Get-Content logs\django.log -Encoding UTF8

# 或使用支持UTF-8的编辑器打开
```

---

## 🔒 安全提示

1. **日志包含敏感信息**
   - 用户名、机器人名称
   - Webhook URL
   - 消息内容

2. **不要提交到Git**
   - 已添加到`.gitignore`
   - 导出的日志也不要提交

3. **定期清理**
   - 建议每月清理一次旧日志
   - 生产环境可设置定时任务自动清理

4. **权限控制**
   - Linux系统建议设置日志文件权限为600
   - 仅服务运行用户可访问

---

## 📚 相关文档

- [LOGS_GUIDE.md](LOGS_GUIDE.md) - 详细日志使用指南
- [README.md](../README.md) - 项目主文档
- [PORT_CHANGE_80.md](PORT_CHANGE_80.md) - 端口配置说明

---

**配置完成时间**: 2026-01-30

## 下一步操作

1. ✅ 重启服务以应用日志配置
2. ✅ 发送测试请求生成日志
3. ✅ 使用 `view_logs.bat` 或 `logs.sh` 查看日志
4. ✅ 使用 `diagnose_400.bat` 诊断400错误
5. ✅ 根据日志信息排查问题
