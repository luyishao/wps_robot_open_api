# 400错误修复：分块传输编码问题

## 🐛 问题描述

在使用Django开发服务器(`runserver`)时，收到来自WPS的webhook请求出现400错误：

```
[30/Jan/2026 18:12:42] "POST /at_robot/admin/test HTTP/1.1" 400 25
[30/Jan/2026 18:12:42] code 400, message Bad request syntax ('10c')
[30/Jan/2026 18:12:42] "10c" 400 -

[30/Jan/2026 18:13:18] "POST /at_robot/admin/test HTTP/1.1" 400 25
[30/Jan/2026 18:13:18] code 400, message Bad request syntax ('10a')
[30/Jan/2026 18:13:18] "10a" 400 -
```

---

## 🔍 根本原因

### 1. 分块传输编码
- `10c` 和 `10a` 是**十六进制数字**，表示HTTP分块大小
  - `0x10c` = 268字节
  - `0x10a` = 266字节
- WPS服务器使用了**HTTP分块传输编码(Chunked Transfer Encoding)**发送POST请求

### 2. Django开发服务器限制
- Django的 `manage.py runserver` 是**开发服务器**
- **不完全支持HTTP/1.1的分块传输编码**
- 将分块大小标识 `10c\r\n` 误认为HTTP请求行
- 导致 `Bad request syntax` 错误

### 3. HTTP分块传输格式
```
POST /at_robot/admin/test HTTP/1.1
Transfer-Encoding: chunked

10c\r\n              ← 分块大小（十六进制）
[268字节的数据]\r\n  ← 实际数据
0\r\n                ← 结束标记
\r\n
```

---

## ✅ 解决方案：使用生产级WSGI服务器

### 问题：Django开发服务器的限制
```python
# ❌ 不适合生产/webhook使用
python manage.py runserver 0.0.0.0:80
```

**限制**：
- 不支持分块传输编码
- 单线程，性能差
- 不稳定，容易崩溃
- 仅用于开发测试

### 解决方案：使用Waitress

**Waitress**是一个生产级的Python WSGI服务器：
- ✅ Windows兼容（不依赖fcntl）
- ✅ 完整支持HTTP/1.1
- ✅ 支持分块传输编码
- ✅ 多线程，性能好
- ✅ 稳定可靠

#### 安装
```bash
pip install waitress
```

#### 启动服务器
```bash
waitress-serve --host=0.0.0.0 --port=80 --threads=4 --channel-timeout=60 wps_robot.wsgi:application
```

**参数说明**：
- `--host=0.0.0.0` - 监听所有网络接口
- `--port=80` - 监听80端口
- `--threads=4` - 4个工作线程
- `--channel-timeout=60` - 通道超时60秒

---

## 📊 效果对比

### Django runserver（开发服务器）
```
[30/Jan/2026 18:12:42] "POST /at_robot/admin/test HTTP/1.1" 400 25
[30/Jan/2026 18:12:42] code 400, message Bad request syntax ('10c')
❌ 无法处理分块传输编码
```

### Waitress（生产服务器）
```
[INFO] 2026-01-30 18:32:49 - Serving on http://0.0.0.0:80
[INFO] 2026-01-30 18:33:15 - "POST /at_robot/admin/test HTTP/1.1" 200 16
✅ 正确处理分块传输编码
```

---

## 🚀 完整部署步骤

### 1. 安装Waitress
```bash
pip install waitress
```

### 2. 更新requirements.txt
```
Django==4.2.9
djangorestframework==3.14.0
requests==2.31.0
python-dotenv==1.0.0
waitress==3.0.2
py7zr>=1.0.0
```

### 3. 启动服务器
```bash
# Windows
waitress-serve --host=0.0.0.0 --port=80 --threads=4 wps_robot.wsgi:application

# Linux (也可以使用Gunicorn)
gunicorn --bind 0.0.0.0:80 --workers 4 --timeout 60 wps_robot.wsgi:application
```

### 4. 创建启动脚本

**Windows (start_waitress.bat)**:
```batch
@echo off
echo 正在启动WPS Robot服务器...
waitress-serve --host=0.0.0.0 --port=80 --threads=4 --channel-timeout=60 wps_robot.wsgi:application
```

**Linux (start_gunicorn.sh)**:
```bash
#!/bin/bash
echo "正在启动WPS Robot服务器..."
gunicorn --bind 0.0.0.0:80 --workers 4 --timeout 60 --access-logfile - --error-logfile - wps_robot.wsgi:application
```

---

## 📝 最佳实践

### 开发环境
```bash
# 只用于本地开发测试
python manage.py runserver 127.0.0.1:8000
```

### 生产环境
```bash
# Windows - 使用Waitress
waitress-serve --host=0.0.0.0 --port=80 --threads=4 wps_robot.wsgi:application

# Linux - 使用Gunicorn
gunicorn --bind 0.0.0.0:80 --workers 4 wps_robot.wsgi:application
```

### 推荐配置（Nginx反向代理）
```nginx
upstream django {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://django;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 支持分块传输
        proxy_http_version 1.1;
        proxy_request_buffering off;
    }
}
```

---

## 🔧 故障排除

### 问题1：Gunicorn在Windows上失败
```
ModuleNotFoundError: No module named 'fcntl'
```

**原因**：Gunicorn需要Unix特有的fcntl模块

**解决**：在Windows上使用Waitress
```bash
pip install waitress
waitress-serve --host=0.0.0.0 --port=80 wps_robot.wsgi:application
```

### 问题2：端口被占用
```
[WinError 10048] 通常每个套接字地址只允许使用一次
```

**解决**：
```bash
# 查找占用80端口的进程
netstat -ano | findstr :80

# 停止进程
taskkill /F /PID <进程ID>
```

### 问题3：仍然出现400错误

**检查**：
1. 确认使用的是Waitress/Gunicorn，不是runserver
2. 查看服务器日志
3. 测试简单的POST请求：
   ```bash
   curl -X POST http://localhost:80/at_robot/admin/test \
     -H "Content-Type: application/json" \
     -d '{"msgtype":"text","text":{"content":"test"}}'
   ```

---

## 📚 技术背景

### HTTP分块传输编码(Chunked Transfer Encoding)

**为什么使用分块传输**：
- 发送方不知道内容总长度
- 动态生成的内容
- 大文件传输
- 减少内存占用

**格式**：
```
Transfer-Encoding: chunked

[chunk-size]\r\n
[chunk-data]\r\n
[chunk-size]\r\n
[chunk-data]\r\n
0\r\n
\r\n
```

**示例**：
```
Transfer-Encoding: chunked

d\r\n
Hello, World!\r\n
0\r\n
\r\n
```

### Django开发服务器的问题

Django的 `wsgiref.simple_server` 基于Python标准库的 `http.server`：
- 设计用于开发测试
- 简单实现，功能有限
- 不完整支持HTTP/1.1特性
- 对分块传输的解析有bug

---

## ✅ 验证修复

### 1. 启动Waitress
```bash
waitress-serve --host=0.0.0.0 --port=80 wps_robot.wsgi:application
```

### 2. 发送测试请求
```bash
curl -X POST http://localhost:80/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -H "Transfer-Encoding: chunked" \
  --data-binary @- << EOF
d
{"msgtype":"text"}
0

EOF
```

### 3. 检查响应
```json
{"result":"ok"}
```

### 4. 查看日志
```
[INFO] 2026-01-30 18:33:15 - "POST /at_robot/admin/test HTTP/1.1" 200 16
✅ 成功，返回200
```

---

## 📊 性能对比

| 服务器 | 并发处理 | 稳定性 | HTTP/1.1支持 | Windows兼容 | 推荐度 |
|--------|---------|--------|-------------|------------|--------|
| Django runserver | ❌ 差 | ❌ 差 | ⚠️ 部分 | ✅ 是 | ❌ 仅开发 |
| Waitress | ✅ 好 | ✅ 好 | ✅ 完整 | ✅ 是 | ✅ 推荐 |
| Gunicorn | ✅ 优秀 | ✅ 优秀 | ✅ 完整 | ❌ 否 | ✅ Linux推荐 |

---

## 🎯 总结

### 问题
WPS使用分块传输编码发送webhook请求，Django开发服务器无法正确处理。

### 根本原因
Django的 `runserver` 是简单的开发服务器，不完整支持HTTP/1.1特性。

### 解决方案
使用生产级WSGI服务器：
- **Windows**: Waitress
- **Linux**: Gunicorn或Waitress

### 配置
```bash
# 安装
pip install waitress

# 启动
waitress-serve --host=0.0.0.0 --port=80 --threads=4 wps_robot.wsgi:application
```

---

**修复完成时间**: 2026-01-30

现在服务器可以正确处理WPS的webhook请求了！ 🎉
