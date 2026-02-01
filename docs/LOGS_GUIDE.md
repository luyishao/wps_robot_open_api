# 日志管理指南

## 📋 关于你的错误

你遇到的错误：
```
[30/Jan/2026 18:13:18] "POST /at_robot/admin/test HTTP/1.1" 400 25
[30/Jan/2026 18:13:18] code 400, message Bad request syntax ('10a')
[30/Jan/2026 18:13:18] "10a" 400 -
```

**错误分析**：
- `400 Bad request syntax` - HTTP请求格式错误
- `'10a'` - 这不是一个有效的HTTP请求
- 可能原因：
  1. WPS发送的请求格式不正确
  2. 中间有代理或防火墙篡改了请求
  3. 使用了非标准的HTTP客户端
  4. 网络传输过程中数据损坏

---

## 🔍 日志系统配置

项目已配置完整的日志系统，日志文件保存在 `logs/` 目录：

### 日志文件说明

| 日志文件 | 说明 | 内容 |
|---------|------|------|
| `django.log` | Django主日志 | 所有INFO及以上级别的日志 |
| `error.log` | 错误日志 | 仅ERROR级别的日志 |
| `webhook.log` | Webhook专用日志 | 机器人webhook相关的详细日志 |

### 日志级别

- **DEBUG**: 详细的调试信息
- **INFO**: 一般信息
- **WARNING**: 警告信息
- **ERROR**: 错误信息
- **CRITICAL**: 严重错误

### 日志轮转

- 单个日志文件最大：10MB
- 保留备份数量：5-10个
- 自动轮转，旧文件添加 `.1`, `.2` 等后缀

---

## 🚀 快速查看日志

### Windows系统

**方法1：使用批处理脚本（推荐）**
```batch
# 双击运行
view_logs.bat

# 或命令行运行
.\view_logs.bat
```

**方法2：使用PowerShell**
```powershell
# 查看最后100行Django日志
Get-Content logs\django.log -Tail 100 -Encoding UTF8

# 查看错误日志
Get-Content logs\error.log -Tail 100 -Encoding UTF8

# 查看Webhook日志
Get-Content logs\webhook.log -Tail 100 -Encoding UTF8

# 实时跟踪日志
Get-Content logs\django.log -Wait -Tail 50
```

**方法3：使用记事本**
```batch
# 直接打开日志文件
notepad logs\django.log
notepad logs\error.log
notepad logs\webhook.log
```

### Linux/MacOS系统

**使用Shell脚本（推荐）**
```bash
# 添加执行权限
chmod +x logs.sh

# 查看Django日志
./logs.sh

# 查看错误日志
./logs.sh --view-error

# 查看Webhook日志
./logs.sh --view-webhook

# 查看最后500行
./logs.sh --tail=500

# 实时跟踪日志
./logs.sh --follow
./logs.sh --view-webhook --follow
```

**使用Linux命令**
```bash
# 查看最后100行
tail -n 100 logs/django.log

# 实时跟踪
tail -f logs/webhook.log

# 查看并搜索
grep "ERROR" logs/error.log

# 统计错误数量
grep -c "ERROR" logs/error.log
```

---

## 📦 导出日志

### Windows

**使用批处理脚本**
```batch
.\view_logs.bat
# 选择 [4] 导出所有日志
# 或选择 [5] 仅导出错误日志
```

日志将导出到 `logs_export/` 目录

### Linux/MacOS

```bash
# 导出所有日志（自动打包为.tar.gz）
./logs.sh --export

# 仅导出错误日志
./logs.sh --export-error
```

导出文件位置：`logs_export/logs_YYYYMMDD_HHMMSS.tar.gz`

---

## 🔧 排查你的问题

### 步骤1：查看详细错误日志

```bash
# Windows
.\view_logs.bat
# 选择 [2] 查看错误日志

# Linux
./logs.sh --view-error
```

### 步骤2：查看Webhook日志

```bash
# Windows
.\view_logs.bat
# 选择 [3] 查看Webhook日志

# Linux
./logs.sh --view-webhook
```

### 步骤3：搜索特定错误

```powershell
# Windows - 搜索400错误
Select-String -Path "logs\*.log" -Pattern "400" | Select-Object -Last 20

# Linux - 搜索400错误
grep -r "400" logs/ | tail -20
```

### 步骤4：查看完整请求信息

```powershell
# Windows - 查看包含"at_robot"的请求
Select-String -Path "logs\webhook.log" -Pattern "at_robot" -Context 3,3

# Linux
grep -A 3 -B 3 "at_robot" logs/webhook.log
```

---

## 🐛 常见错误及解决方案

### 1. 400 Bad Request

**可能原因**：
- 请求格式不正确
- Content-Type不匹配
- 请求体格式错误

**解决方法**：
```python
# 检查webhook.log中的原始请求数据
# 确认WPS发送的数据格式是否正确
```

### 2. 500 Internal Server Error

**可能原因**：
- 代码逻辑错误
- Hook脚本执行失败
- 数据库错误

**解决方法**：
```bash
# 查看详细错误堆栈
./logs.sh --view-error
```

### 3. 日志文件不存在

**原因**：服务还未启动或未接收到请求

**解决方法**：
```bash
# 启动服务
./start.sh

# 发送测试请求触发日志记录
curl -X POST http://localhost:80/at_robot/admin/test -H "Content-Type: application/json" -d '{"msgtype":"text","text":{"content":"test"}}'
```

---

## 📊 日志分析

### 统计错误数量

```powershell
# Windows
(Select-String -Path "logs\error.log" -Pattern "ERROR").Count

# Linux
./logs.sh --analyze
```

### 查找特定时间段的日志

```powershell
# Windows - 查找今天的错误
Select-String -Path "logs\error.log" -Pattern "$(Get-Date -Format 'yyyy-MM-dd')"

# Linux
grep "$(date +%Y-%m-%d)" logs/error.log
```

### 按请求路径分组统计

```bash
# Linux
grep "POST /at_robot" logs/webhook.log | awk '{print $7}' | sort | uniq -c | sort -rn
```

---

## 🧹 清理日志

### 自动清理（推荐）

日志系统已配置自动轮转：
- 单个文件超过10MB自动创建新文件
- 保留最近5-10个备份文件
- 不需要手动清理

### 手动清理旧日志

```bash
# Windows
.\view_logs.bat
# 选择 [7] 清理旧日志

# Linux - 清理30天前的日志
./logs.sh --clean
```

### 完全清空日志

```powershell
# Windows - 慎用！
Remove-Item logs\*.log* -Force

# Linux - 慎用！
rm -f logs/*.log*
```

---

## 📝 在代码中添加日志

如果需要在代码中添加自定义日志：

```python
import logging

# 获取logger
logger = logging.getLogger('robots.webhook')

# 记录不同级别的日志
logger.debug('调试信息: 变量值=%s', some_var)
logger.info('收到webhook请求: %s', request.path)
logger.warning('警告: 机器人未配置hook脚本')
logger.error('错误: 发送消息失败 - %s', error_msg)
logger.critical('严重错误: 数据库连接失败')

# 记录异常
try:
    # 代码
    pass
except Exception as e:
    logger.exception('处理消息时发生异常')  # 自动记录堆栈跟踪
```

---

## 🔒 日志安全

### 敏感信息保护

日志中可能包含：
- 用户信息
- Webhook URL
- 消息内容

**建议**：
1. 定期清理旧日志
2. 不要将日志提交到Git
3. 导出日志时注意保护隐私
4. 生产环境关闭DEBUG级别

### 日志权限

```bash
# Linux - 设置日志文件权限
chmod 600 logs/*.log

# 仅所有者可读写
```

---

## 📞 获取技术支持

导出日志后，你可以：

1. **查看详细错误信息**
   - 完整的错误堆栈
   - 请求参数和响应

2. **分析问题原因**
   - 时间戳
   - 请求路径
   - 错误类型

3. **提供给技术支持**
   - 导出的日志文件
   - 错误复现步骤
   - 环境信息

---

## 🎯 针对你的400错误的建议

1. **查看完整请求数据**
   ```bash
   ./logs.sh --view-webhook
   # 查找 "at_robot/admin/test" 相关的日志
   ```

2. **检查WPS配置**
   - 确认Webhook URL格式正确
   - 确认WPS机器人配置无误
   - 测试其他WPS机器人是否正常

3. **测试连接**
   ```bash
   # 使用curl测试
   curl -v -X GET http://localhost:80/at_robot/admin/test
   curl -v -X POST http://localhost:80/at_robot/admin/test \
     -H "Content-Type: application/json" \
     -d '{"msgtype":"text","text":{"content":"test"}}'
   ```

4. **启用DEBUG模式**
   ```bash
   # 编辑 .env 文件
   DEBUG=True
   
   # 重启服务
   ./stop.sh
   ./start.sh
   
   # 查看详细错误信息
   ./logs.sh --follow
   ```

---

## 📚 相关文档

- [README.md](../README.md) - 项目说明
- [SHELL_SCRIPTS_README.md](SHELL_SCRIPTS_README.md) - Shell脚本说明
- [PORT_CHANGE_80.md](PORT_CHANGE_80.md) - 端口配置说明

---

**更新日期**: 2026-01-30
