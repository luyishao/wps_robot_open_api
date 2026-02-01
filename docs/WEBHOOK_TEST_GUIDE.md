# 🧪 Webhook回调地址变更测试指南

## 📋 测试清单

### ✅ 测试1：查看新的回调地址

**步骤**：
1. 访问 http://127.0.0.1:8080/
2. 使用 admin/admin123456 登录
3. 进入任意机器人详情页
4. 查看"Webhook回调地址"

**预期结果**：
```
http://127.0.0.1:8080/callback/用户名/机器人名称
```

例如：
```
http://127.0.0.1:8080/callback/admin/test
```

**检查点**：
- ✅ URL中包含 `/callback/` 前缀
- ✅ 格式为：`协议://域名:端口/callback/用户名/机器人名`
- ✅ 可以点击"复制"按钮成功复制

---

### ✅ 测试2：测试GET请求验证（WPS回调地址验证）

**使用curl测试**：
```bash
curl -X GET http://127.0.0.1:8080/callback/admin/test
```

**预期结果**：
- HTTP状态码：200
- 响应体：`{"result":"ok"}`

**说明**：
WPS在配置webhook地址时会发送GET请求验证地址有效性，必须返回`{"result":"ok"}`。

**检查点**：
- ✅ GET请求成功
- ✅ 返回正确的JSON格式
- ✅ result字段值为"ok"

---

### ✅ 测试3：使用curl测试POST webhook接收

**简单测试**：
```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试消息"}}'
```

**预期结果**：
- HTTP状态码：200
- 响应体：`{"result":"ok"}` 或hook脚本的自定义响应

**检查点**：
- ✅ 请求成功
- ✅ 在消息列表中看到新的接收消息
- ✅ 消息状态为"成功"

---

### ✅ 测试4：测试Markdown消息

```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{
    "msgtype": "markdown",
    "markdown": {
      "text": "**测试标题**\n\n这是内容"
    }
  }'
```

**预期结果**：
- 消息成功接收
- 内容类型为markdown

---

### ✅ 测试5：测试卡片消息

```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{
    "msgtype": "card",
    "card": {
      "header": {
        "title": {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "测试卡片"
          }
        }
      },
      "elements": [
        {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "这是卡片内容"
          }
        }
      ]
    }
  }'
```

**预期结果**：
- 卡片消息成功接收
- 消息记录中显示完整的card结构

---

### ✅ 测试6：验证无需登录

**在未登录状态下测试**：

```bash
# 不带任何cookie或认证信息
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"无需登录的测试"}}'
```

**预期结果**：
- ✅ 请求成功（不会跳转到登录页）
- ✅ 返回200状态码
- ✅ 消息正常记录

**检查点**：
- ❌ 不应该返回302重定向
- ❌ 不应该要求登录
- ✅ 应该直接处理消息

---

### ✅ 测试7：测试旧URL（应该失败）

**测试旧格式URL**：
```bash
# 旧格式：不含 /callback/ 前缀
curl -X POST http://127.0.0.1:8080/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试"}}'
```

**预期结果**：
- ❌ 返回404错误
- ❌ 或者被其他路由捕获

**说明**：
旧格式的URL已经废弃，确认它不再工作是正确的。

---

### ✅ 测试8：错误处理测试

#### 7.1 测试机器人不存在
```bash
curl -X POST http://127.0.0.1:8080/callback/admin/nonexistent \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试"}}'
```

**预期结果**：
- HTTP 404
- 响应：`{"error":"Robot not found"}`

#### 7.2 测试无效JSON
```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d 'invalid json'
```

**预期结果**：
- HTTP 400
- 响应：`{"error":"Invalid JSON"}`

#### 8.3 测试GET请求（应该成功）
```bash
curl -X GET http://127.0.0.1:8080/callback/admin/test
```

**预期结果**：
- HTTP 200
- 响应：`{"result":"ok"}`

---

### ✅ 测试9：Hook脚本执行

**前提**：机器人配置了hook脚本

```bash
curl -X POST http://127.0.0.1:8080/callback/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"触发hook"}}'
```

**预期结果**：
- Hook脚本被执行
- 如果hook返回响应，应该在响应中看到
- 检查消息记录的response_data字段

---

### ✅ 测试10：消息数量限制

**步骤**：
1. 设置机器人的max_message_count=5
2. 连续发送10条消息
3. 检查消息列表

```bash
# 发送10条消息
for i in {1..10}; do
  curl -X POST http://127.0.0.1:8080/callback/admin/test \
    -H "Content-Type: application/json" \
    -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"消息$i\"}}"
  sleep 0.5
done
```

**预期结果**：
- 消息列表中只保留最新的5条
- 旧消息被自动删除

---

## 📊 测试结果检查表

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 查看新回调地址 | ⬜ | 包含/callback/前缀 |
| GET请求验证 | ⬜ | 返回{"result":"ok"} |
| 发送文本消息 | ⬜ | curl测试成功 |
| 发送Markdown | ⬜ | 格式正确 |
| 发送卡片消息 | ⬜ | card结构完整 |
| 无需登录验证 | ⬜ | 未登录可访问 |
| 旧URL失效 | ⬜ | 返回404 |
| 机器人不存在 | ⬜ | 返回404 |
| 无效JSON | ⬜ | 返回400 |
| GET请求成功 | ⬜ | 返回200 |
| Hook脚本执行 | ⬜ | 脚本正常运行 |
| 消息数量限制 | ⬜ | 自动清理旧消息 |

---

## 🔍 验证要点

### 1. URL格式正确
```
✅ http://127.0.0.1:8080/callback/admin/test
❌ http://127.0.0.1:8080/admin/test
```

### 2. 无需认证
- 不需要Cookie
- 不需要CSRF令牌
- 不需要登录状态

### 3. 只接受GET和POST
- GET ✅ 返回验证信息
- POST ✅ 处理消息
- PUT ❌
- DELETE ❌

### 4. 消息正常记录
- 在机器人详情页查看消息列表
- 确认消息内容完整
- 确认时间戳正确

---

## 🐛 常见问题

### 问题1：404错误
**可能原因**：
- 使用了旧的URL格式
- 用户名或机器人名错误

**解决**：
- 确认URL包含`/callback/`前缀
- 检查用户名和机器人名拼写

### 问题2：Robot not found
**可能原因**：
- 机器人不存在
- 机器人已禁用
- 用户名错误

**解决**：
- 在后台检查机器人是否存在
- 确认机器人状态为"启用"
- 验证用户名正确

### 问题3：消息未记录
**可能原因**：
- JSON格式错误
- Content-Type不正确

**解决**：
- 验证JSON格式
- 确认Header包含`Content-Type: application/json`

---

## 📝 测试报告模板

```
测试时间：____________________
测试人员：____________________
服务器地址：http://127.0.0.1:8080/

测试结果：
[ ] 所有测试通过
[ ] 部分测试失败（详见备注）

失败项目：
1. ________________________________
2. ________________________________

备注：
________________________________
________________________________
```

---

**更新时间**: 2026-01-30  
**版本**: v2.2  
**测试覆盖**: Webhook回调地址变更
