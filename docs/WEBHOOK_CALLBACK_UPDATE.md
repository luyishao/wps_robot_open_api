# Webhook回调地址格式变更说明

## 📋 变更内容

### 变更前
Webhook回调地址格式：
```
<域名>/<用户名>/<机器人名称>
```

示例：
```
http://127.0.0.1:8080/admin/test
```

### 变更后
Webhook回调地址格式：
```
<域名>/callback/<用户名>/<机器人名称>
```

示例：
```
http://127.0.0.1:8080/callback/admin/test
```

## 🎯 变更原因

1. **路径更加明确**：添加`/callback/`前缀，明确标识这是webhook回调接口
2. **避免路由冲突**：将回调URL与其他页面路由分离
3. **安全性提升**：独立的回调路径便于配置防火墙规则和访问控制
4. **符合RESTful规范**：API路径更加规范和易于理解

## 🔧 技术实现

### 1. URL路由修改

**文件**: `robots/urls.py`

**修改前**:
```python
path('<str:username>/<str:robot_name>', views.webhook_callback, name='webhook_callback'),
```

**修改后**:
```python
path('callback/<str:username>/<str:robot_name>', views.webhook_callback, name='webhook_callback'),
```

### 2. 模型方法修改

**文件**: `robots/models.py`

**修改前**:
```python
def get_webhook_callback_url(self, request=None):
    return f"/{self.owner.username}/{self.name}"
```

**修改后**:
```python
def get_webhook_callback_url(self, request=None):
    return f"/callback/{self.owner.username}/{self.name}"
```

### 3. 无需登录验证

`webhook_callback`视图保持现有配置：
```python
@csrf_exempt
@require_http_methods(["GET", "POST"])
def webhook_callback(request, username, robot_name):
    # 无需 @login_required 装饰器
    # 任何人都可以访问此接口
    
    # GET请求：WPS验证回调地址
    if request.method == 'GET':
        return JsonResponse({'result': 'ok'})
    
    # POST请求：处理消息
    ...
```

## 📝 影响说明

### ✅ 已自动更新
- Webhook回调URL显示（机器人详情页）
- URL路由配置

### ⚠️ 需要用户操作
如果已经在WPS机器人配置中设置了旧的回调地址，需要手动更新：

**旧地址** (已失效):
```
http://yourdomain:8080/admin/test
```

**新地址** (使用这个):
```
http://yourdomain:8080/callback/admin/test
```

## 🧪 测试验证

### 测试1：查看新的回调地址

1. 访问 http://127.0.0.1:8080/
2. 登录系统
3. 进入任意机器人详情页
4. 查看"Webhook回调地址"

**预期结果**:
```
http://127.0.0.1:8080/callback/用户名/机器人名称
```

### 测试2：测试回调接收

使用curl或Postman发送POST请求：

```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{
    "msgtype": "text",
    "text": {
      "content": "测试消息"
    }
  }'
```

**预期结果**:
- 返回状态码: 200
- 响应体: `{"status": "ok"}`
- 消息记录中出现新的接收消息

### 测试3：验证无需登录

在未登录状态下访问回调URL：

```bash
# 不带任何认证信息
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype": "text", "text": {"content": "test"}}'
```

**预期结果**:
- 请求成功处理
- 不会返回登录要求
- 消息正常记录

## 📊 URL路由对比

### 旧路由结构
```
/                           → 控制台（需要登录）
/login/                     → 登录页面
/robots/                    → 机器人列表（需要登录）
/admin/test                 → webhook回调（无需登录）⚠️ 容易混淆
```

### 新路由结构
```
/                           → 控制台（需要登录）
/login/                     → 登录页面
/robots/                    → 机器人列表（需要登录）
/callback/admin/test        → webhook回调（无需登录）✅ 清晰明确
```

## 🔒 安全性说明

### 回调接口特点
- ✅ **CSRF保护已禁用** (`@csrf_exempt`)
- ✅ **无需登录验证**
- ✅ **仅接受POST请求** (`@require_http_methods(["POST"])`)
- ✅ **验证机器人存在性**
- ✅ **验证JSON格式**
- ✅ **记录所有请求**

### 安全建议

1. **生产环境**：
   - 使用HTTPS (443端口)
   - 配置Nginx限流
   - 添加IP白名单（如果WPS提供固定IP）

2. **监控告警**：
   - 监控异常的回调请求
   - 记录失败的回调
   - 定期检查消息日志

## 📚 相关文档更新

需要更新以下文档中的回调地址示例：

- ✅ README.md
- ✅ 机器人详情页面显示
- ✅ API文档（如有）
- ⚠️ WPS机器人配置（需手动更新）

## 🔄 迁移步骤

如果系统已在生产环境运行：

### 步骤1：更新代码
```bash
# 拉取最新代码
git pull

# 重启服务器
python manage.py runserver 8080
```

### 步骤2：通知用户
告知所有用户更新WPS机器人配置中的webhook地址：
- 旧地址：`http://domain/username/robotname`
- 新地址：`http://domain/callback/username/robotname`

### 步骤3：验证
- 检查所有机器人的回调地址显示
- 测试几个机器人的webhook接收
- 查看消息日志确认正常

## ⚠️ 重要提示

### 旧地址已失效
旧格式的回调地址将**不再工作**：
```
http://127.0.0.1:8080/admin/test  ❌ 404错误
```

必须使用新格式：
```
http://127.0.0.1:8080/callback/admin/test  ✅ 正常工作
```

### WPS配置更新
如果之前在WPS机器人后台配置了webhook地址，请务必更新为新格式。

## 📞 问题排查

### 问题1：404错误
**原因**：使用了旧的URL格式  
**解决**：确认URL包含`/callback/`前缀

### 问题2：机器人未找到
**原因**：用户名或机器人名称错误  
**解决**：检查URL中的用户名和机器人名称是否正确

### 问题3：JSON解析错误
**原因**：请求体不是有效的JSON  
**解决**：确认Content-Type为application/json，数据格式正确

---

**更新时间**: 2026-01-30  
**版本**: v2.2  
**影响**: 所有webhook回调URL需要更新
