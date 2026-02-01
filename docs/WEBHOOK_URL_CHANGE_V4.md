# Webhook URL 格式变更说明 (v4.0)

## 📅 更新日期
2026-01-30

## 🔄 变更内容

### 新的URL格式
```
/at_robot/{username}/{robot_name}
```

### 完整示例
```
http://your-domain.com:8080/at_robot/admin/myrobot
```

## 📋 版本历史

### v4.0 (当前版本) - 2026-01-30
- **新格式**: `/at_robot/{username}/{robot_name}`
- **前缀**: `at_robot` (@ Robot - 艾特机器人)
- **状态**: ✅ 当前使用

### v3.0 (已废弃) - 2026-01-30
- **格式**: `/xz_robot/{username}/{robot_name}`
- **前缀**: `xz_robot`
- **状态**: ❌ 已废弃

### v2.0 (已废弃)
- **格式**: `/callback/{username}/{robot_name}`
- **前缀**: `callback`
- **状态**: ❌ 已废弃

## 🔧 代码变更

### 1. URL路由配置
**文件**: `robots/urls.py`

```python
# 旧配置 (v3.0)
path('xz_robot/<str:username>/<str:robot_name>', views.webhook_callback, name='webhook_callback'),

# 新配置 (v4.0)
path('at_robot/<str:username>/<str:robot_name>', views.webhook_callback, name='webhook_callback'),
```

### 2. Model方法更新
**文件**: `robots/models.py`

```python
# 旧方法 (v3.0)
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址（相对路径）"""
    return f"/xz_robot/{self.owner.username}/{self.name}"

# 新方法 (v4.0)
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址（相对路径）"""
    return f"/at_robot/{self.owner.username}/{self.name}"
```

## 📝 更新步骤

### 对于新部署
直接使用新格式即可，无需额外操作。

### 对于已有部署

#### 步骤1：更新代码
```bash
# 拉取最新代码
git pull

# 重启服务
./stop.sh
./start.sh
```

#### 步骤2：更新WPS平台配置
1. 登录WPS开放平台
2. 进入你的机器人配置页面
3. 更新Webhook回调地址：
   - 旧地址: `http://your-domain:8080/xz_robot/用户名/机器人名`
   - 新地址: `http://your-domain:8080/at_robot/用户名/机器人名`

#### 步骤3：测试验证
```bash
# 测试GET请求（WPS平台验证）
curl http://your-domain:8080/at_robot/admin/myrobot

# 预期返回
{"result":"ok"}

# 测试POST请求（发送消息）
curl -X POST http://your-domain:8080/at_robot/admin/myrobot \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试消息"}}'
```

## ⚠️ 重要提醒

### 兼容性说明
- ❌ 旧的URL格式 `/xz_robot/` 不再支持
- ❌ 更旧的URL格式 `/callback/` 不再支持
- ✅ 必须使用新格式 `/at_robot/`

### 功能保持不变
- ✅ 支持GET请求验证
- ✅ 支持POST请求接收消息
- ✅ 无需登录认证
- ✅ 无需CSRF令牌
- ✅ 自动记录所有请求

## 📊 对比表格

| 项目 | v2.0 (废弃) | v3.0 (废弃) | v4.0 (当前) |
|------|------------|------------|------------|
| URL前缀 | `/callback/` | `/xz_robot/` | `/at_robot/` |
| 格式 | `/callback/{user}/{robot}` | `/xz_robot/{user}/{robot}` | `/at_robot/{user}/{robot}` |
| 状态 | ❌ 已废弃 | ❌ 已废弃 | ✅ 使用中 |
| 支持日期 | - | 2026-01-30 (同日废弃) | 2026-01-30 起 |

## 🎯 变更原因

### 为什么改为 `at_robot`？

1. **语义更清晰**
   - `at_robot` = @ Robot (艾特机器人)
   - 符合"@机器人"的使用场景
   - 更容易理解和记忆

2. **命名规范**
   - 使用通用的英文单词
   - 避免拼音缩写 (xz)
   - 提高代码可读性

3. **统一风格**
   - 与行业惯例保持一致
   - 便于国际化扩展

## 🧪 测试用例

### 测试1：验证GET请求
```bash
curl -X GET http://localhost:8080/at_robot/admin/test
# 预期: {"result":"ok"}
```

### 测试2：发送文本消息
```bash
curl -X POST http://localhost:8080/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -d '{
    "msgtype": "text",
    "text": {
      "content": "Hello, Robot!"
    }
  }'
```

### 测试3：发送Markdown消息
```bash
curl -X POST http://localhost:8080/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -d '{
    "msgtype": "markdown",
    "markdown": {
      "text": "# 测试标题\n\n这是内容"
    }
  }'
```

## 📚 相关文档

- [README.md](../README.md) - 主文档
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速参考
- [功能清单.md](功能清单.md) - 功能说明

## 🔍 检查清单

使用以下清单确保迁移完成：

- [ ] 已更新代码到最新版本
- [ ] 已重启服务
- [ ] 已在WPS平台更新webhook URL
- [ ] GET请求测试通过
- [ ] POST请求测试通过
- [ ] 能正常接收WPS消息
- [ ] 能正常发送消息到WPS
- [ ] 消息记录功能正常

## ❓ 常见问题

### Q1: 旧的URL还能用吗？
A: 不能，旧格式 `/xz_robot/` 和 `/callback/` 已完全废弃。

### Q2: 如何快速切换？
A: 
1. 更新代码并重启服务
2. 在WPS平台修改webhook地址
3. 测试新地址是否正常工作

### Q3: 是否需要数据库迁移？
A: 不需要，这只是URL路由的变更，不涉及数据库结构。

### Q4: 已有的消息记录会丢失吗？
A: 不会，所有历史消息记录保持不变。

### Q5: 是否影响Hook脚本？
A: 不影响，Hook脚本的处理逻辑完全不变。

## 📞 技术支持

如遇到问题：
1. 查看服务日志: `./status.sh --logs`
2. 测试服务状态: `./status.sh --test`
3. 检查URL配置是否正确
4. 确认WPS平台的webhook地址已更新

---

**更新人**: AI Assistant  
**版本**: v4.0  
**生效日期**: 2026-01-30
