# 🔧 Webhook响应格式统一说明

## 📋 变更说明

根据WPS机器人API文档要求，webhook回调接口的GET和POST请求都应该返回`{"result":"ok"}`。

## ✅ 修改内容

### 之前的实现
- **GET请求**：返回 `{"result":"ok"}` ✅
- **POST请求**：返回 `{"status":"ok"}` ❌

### 修改后
- **GET请求**：返回 `{"result":"ok"}` ✅
- **POST请求**：返回 `{"result":"ok"}` ✅

## 🔧 代码修改

**文件**：`robots/views.py`

**修改位置**：webhook_callback函数的返回值

**修改前**：
```python
if response_data:
    return JsonResponse(response_data)
else:
    return JsonResponse({'status': 'ok'})
```

**修改后**：
```python
if response_data:
    return JsonResponse(response_data)
else:
    return JsonResponse({'result': 'ok'})
```

## 📊 响应格式说明

### 1. GET请求（验证）
**用途**：WPS验证webhook地址有效性

**请求示例**：
```bash
GET http://yourdomain:8080/callback/username/robotname
```

**响应**：
```json
{"result": "ok"}
```

### 2. POST请求（接收消息）
**用途**：接收WPS推送的机器人消息

**请求示例**：
```bash
POST http://yourdomain:8080/callback/username/robotname
Content-Type: application/json

{
  "msgtype": "text",
  "text": {
    "content": "用户消息"
  }
}
```

**响应**：

#### 情况1：无hook脚本或hook脚本无返回值
```json
{"result": "ok"}
```

#### 情况2：hook脚本有自定义返回值
```json
{
  "custom_field": "custom_value",
  ...
}
```
返回hook脚本的`process`函数返回的dict内容。

## 🧪 测试验证

### 测试1：GET请求
```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:8080/callback/admin/test" -Method GET -UseBasicParsing
```

**预期结果**：
```
StatusCode: 200
Content: {"result": "ok"}
```

### 测试2：POST请求（无hook脚本）
```powershell
$body = '{"msgtype":"text","text":{"content":"test"}}'
Invoke-WebRequest -Uri "http://127.0.0.1:8080/callback/admin/test" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
```

**预期结果**：
```
StatusCode: 200
Content: {"result": "ok"}
```

### 测试3：POST请求（有hook脚本返回值）
如果机器人配置了hook脚本并返回自定义数据，响应将是hook脚本的返回值。

**hook脚本示例** (`hooks/custom_hook.py`):
```python
def process(data):
    """处理接收到的消息"""
    return {
        "result": "ok",
        "message": "自定义响应",
        "received": data.get("msgtype", "unknown")
    }
```

**响应**：
```json
{
  "result": "ok",
  "message": "自定义响应",
  "received": "text"
}
```

## 📝 Hook脚本说明

### Hook脚本返回值处理

1. **无返回值或返回None**：
   - 系统自动返回 `{"result": "ok"}`

2. **返回dict**：
   - 直接作为响应返回给WPS
   - 建议包含`"result": "ok"`字段

3. **返回其他类型**：
   - 被忽略
   - 系统返回 `{"result": "ok"}`

### Hook脚本最佳实践

**推荐写法**：
```python
def process(data):
    """处理接收到的消息"""
    # 处理业务逻辑
    msgtype = data.get("msgtype", "")
    content = data.get("text", {}).get("content", "") if msgtype == "text" else ""
    
    # 返回符合WPS格式的响应
    return {
        "result": "ok",
        "echo": content  # 可选的额外字段
    }
```

**简单写法**（让系统自动返回）：
```python
def process(data):
    """处理接收到的消息"""
    # 只做业务处理，不返回响应
    print(f"收到消息: {data}")
    # return None 或不写return语句
```

## 🔄 完整请求响应流程

### GET请求流程
```
WPS
  ↓ GET /callback/username/robotname
验证机器人存在
  ↓
{"result": "ok"}
  ↓
WPS：验证成功 ✅
```

### POST请求流程（无hook脚本）
```
WPS
  ↓ POST /callback/username/robotname
验证机器人存在
  ↓
解析JSON
  ↓
保存消息记录
  ↓
清理旧消息
  ↓
{"result": "ok"}
  ↓
WPS：接收成功 ✅
```

### POST请求流程（有hook脚本）
```
WPS
  ↓ POST /callback/username/robotname
验证机器人存在
  ↓
解析JSON
  ↓
保存消息记录
  ↓
执行hook脚本
  ↓
hook脚本返回自定义响应
  ↓
返回hook响应给WPS
  ↓
清理旧消息
  ↓
WPS：接收成功 ✅
```

## 📚 相关文档

已更新的文档：
1. ✅ `robots/views.py` - webhook_callback函数
2. ✅ `WEBHOOK_GET_SUPPORT.md` - GET请求支持说明
3. ✅ `WEBHOOK_TEST_GUIDE.md` - 测试指南

## ⚠️ 重要提示

### 与WPS API的兼容性

根据WPS机器人API文档：
- ✅ GET请求必须返回 `{"result":"ok"}`（用于验证）
- ✅ POST请求推荐返回 `{"result":"ok"}`（表示接收成功）
- ✅ 可以返回其他字段，但应包含`result`字段

### 错误响应

如果发生错误，仍然返回相应的错误信息：

**机器人不存在**：
```json
{"error": "Robot not found"}
```
HTTP 状态码：404

**JSON格式错误**：
```json
{"error": "Invalid JSON"}
```
HTTP 状态码：400

**服务器内部错误**：
```json
{
  "error": "Internal server error",
  "message": "错误详情"
}
```
HTTP 状态码：500

## 🎯 总结

| 请求类型 | 场景 | 标准响应 | 备注 |
|---------|------|---------|------|
| GET | WPS验证 | `{"result":"ok"}` | 固定返回 |
| POST | 无hook | `{"result":"ok"}` | 系统默认 |
| POST | 有hook | hook返回值 | 建议包含result字段 |
| 任何 | 错误 | `{"error":"..."}` | 带相应HTTP状态码 |

**关键要点**：
1. ✅ GET和POST成功时都返回包含`"result":"ok"`的JSON
2. ✅ Hook脚本可以自定义返回内容
3. ✅ 错误情况返回`error`字段和对应状态码
4. ✅ 符合WPS机器人API规范

---

**更新时间**：2026-01-30  
**版本**：v2.4  
**修复内容**：统一webhook响应格式为`{"result":"ok"}`
