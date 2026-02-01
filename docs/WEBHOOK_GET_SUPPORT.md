# 🔧 Webhook回调地址GET请求支持说明

## 📋 问题描述

**问题**：机器人收到回调地址的GET请求后没有按文档要求回复`{"result":"ok"}`

**原因**：原实现中webhook回调接口只支持POST请求，使用了`@require_http_methods(["POST"])`装饰器。

## ✅ 解决方案

### WPS文档要求

根据WPS机器人API文档，webhook回调地址需要：
1. **GET请求**：用于验证回调地址有效性，必须返回`{"result":"ok"}`
2. **POST请求**：用于接收实际的消息推送

### 修改内容

**文件**：`robots/views.py`

**修改前**：
```python
@csrf_exempt
@require_http_methods(["POST"])
def webhook_callback(request, username, robot_name):
    """接收webhook回调"""
    try:
        # 获取用户和机器人
        try:
            user = User.objects.get(username=username)
            robot = Robot.objects.get(owner=user, name=robot_name, is_active=True)
        except (User.DoesNotExist, Robot.DoesNotExist):
            return JsonResponse({'error': 'Robot not found'}, status=404)
        
        # 解析请求数据
        try:
            data = json.loads(request.body.decode('utf-8'))
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
        
        # ... 后续处理
```

**修改后**：
```python
@csrf_exempt
@require_http_methods(["GET", "POST"])
def webhook_callback(request, username, robot_name):
    """接收webhook回调"""
    try:
        # 获取用户和机器人
        try:
            user = User.objects.get(username=username)
            robot = Robot.objects.get(owner=user, name=robot_name, is_active=True)
        except (User.DoesNotExist, Robot.DoesNotExist):
            return JsonResponse({'error': 'Robot not found'}, status=404)
        
        # GET请求：WPS验证回调地址
        if request.method == 'GET':
            return JsonResponse({'result': 'ok'})
        
        # POST请求：处理消息
        # 解析请求数据
        try:
            data = json.loads(request.body.decode('utf-8'))
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
        
        # ... 后续处理
```

### 关键变更

1. **装饰器修改**：
   ```python
   # 旧：@require_http_methods(["POST"])
   # 新：@require_http_methods(["GET", "POST"])
   ```

2. **添加GET请求处理**：
   ```python
   # GET请求：WPS验证回调地址
   if request.method == 'GET':
       return JsonResponse({'result': 'ok'})
   ```

3. **POST请求继续原有逻辑**：
   - 解析JSON数据
   - 保存消息记录
   - 执行hook脚本
   - 返回响应

## 🧪 测试验证

### 测试1：GET请求验证

**命令**：
```bash
curl -X GET http://127.0.0.1:8080/callback/admin/test
```

**预期响应**：
```json
{"result": "ok"}
```

**HTTP状态码**：200

### 测试2：POST请求处理

**命令**：
```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试消息"}}'
```

**预期响应**：
```json
{"result": "ok"}
```
或者hook脚本返回的自定义响应

**HTTP状态码**：200

### 测试3：使用浏览器测试

直接在浏览器中访问：
```
http://127.0.0.1:8080/callback/admin/test
```

**预期显示**：
```json
{"result": "ok"}
```

## 📖 WPS机器人配置流程

### 步骤1：配置webhook地址

在WPS机器人管理后台：
1. 进入机器人设置
2. 找到"Webhook回调地址"配置项
3. 输入：`http://yourdomain:8080/callback/username/robotname`

### 步骤2：WPS验证

WPS会向该地址发送GET请求进行验证：
```
GET http://yourdomain:8080/callback/username/robotname
```

**必须返回**：
```json
{"result": "ok"}
```

### 步骤3：验证成功

如果返回正确，WPS会：
- ✅ 标记该回调地址为有效
- ✅ 开始向该地址推送消息（POST请求）

### 步骤4：接收消息

之后WPS会向该地址发送POST请求推送消息：
```
POST http://yourdomain:8080/callback/username/robotname
Content-Type: application/json

{
  "msgtype": "text",
  "text": {
    "content": "用户消息"
  }
}
```

## 🔒 安全说明

### GET请求特点
- ✅ 无需登录验证
- ✅ 无需CSRF令牌
- ✅ 只验证机器人存在性
- ✅ 不记录到消息列表（只是验证）
- ✅ 固定返回`{"result":"ok"}`

### POST请求特点
- ✅ 无需登录验证
- ✅ 无需CSRF令牌
- ✅ 验证机器人存在性
- ✅ 验证JSON格式
- ✅ 记录所有消息
- ✅ 执行hook脚本
- ✅ 默认返回`{"result":"ok"}`（hook脚本可自定义响应）

## 📊 请求流程对比

### GET请求流程
```
WPS → GET /callback/username/robotname
     ↓
验证机器人存在
     ↓
返回 {"result":"ok"}
     ↓
WPS验证成功
```

### POST请求流程
```
WPS → POST /callback/username/robotname
     ↓
验证机器人存在
     ↓
解析JSON数据
     ↓
保存消息记录
     ↓
执行hook脚本
     ↓
清理旧消息
     ↓
返回响应数据
     ↓
WPS接收响应
```

## 🔍 常见问题

### 问题1：GET请求返回404

**原因**：
- 用户名或机器人名错误
- 机器人已禁用
- URL格式错误

**解决**：
- 检查URL格式是否为：`/callback/username/robotname`
- 确认用户名和机器人名正确
- 确认机器人状态为"启用"

### 问题2：GET请求返回错误JSON

**原因**：
- 代码修改未生效
- 服务器未重启

**解决**：
- 检查`robots/views.py`文件修改是否保存
- Django开发服务器会自动重启，等待几秒钟

### 问题3：WPS验证失败

**原因**：
- GET请求返回的JSON格式不正确
- 返回的不是`{"result":"ok"}`

**解决**：
- 使用curl测试GET请求
- 确认返回的JSON完全符合要求
- 检查是否有额外的字段或格式错误

## 📝 代码说明

### 为什么要区分GET和POST

1. **GET请求（验证）**：
   - 用途：让WPS验证webhook地址有效性
   - 特点：轻量、快速、不需要处理消息内容
   - 响应：固定返回`{"result":"ok"}`

2. **POST请求（消息推送）**：
   - 用途：接收WPS推送的实际消息
   - 特点：需要解析JSON、保存数据、执行业务逻辑
   - 响应：默认返回`{"result":"ok"}`，hook脚本可自定义响应

### 为什么GET请求不记录消息

- GET请求只是验证接口可达性
- 不包含实际的消息内容
- 频繁记录会产生无用数据
- 影响数据库性能

### 为什么两种请求都不需要登录

- Webhook是外部服务（WPS）调用的接口
- WPS无法提供用户登录凭证
- 通过URL中的username和robotname来识别目标机器人
- 验证机器人存在性和启用状态即可保证基本安全

## 📚 相关文档更新

已同步更新以下文档：

- ✅ `README.md` - API接口说明
- ✅ `WEBHOOK_CALLBACK_UPDATE.md` - 回调地址变更说明
- ✅ `WEBHOOK_TEST_GUIDE.md` - 测试指南

## 🎯 总结

| 请求方法 | 用途 | 响应 | 是否记录 |
|---------|------|------|---------|
| GET | WPS验证地址 | `{"result":"ok"}` | 否 |
| POST | 接收消息推送 | `{"result":"ok"}` 或hook脚本响应 | 是 |

**关键点**：
1. ✅ 同时支持GET和POST请求
2. ✅ GET请求返回固定格式
3. ✅ POST请求处理完整业务逻辑
4. ✅ 都不需要登录验证
5. ✅ 都验证机器人存在性

---

**更新时间**：2026-01-30  
**版本**：v2.3  
**修复问题**：支持WPS webhook地址GET验证
