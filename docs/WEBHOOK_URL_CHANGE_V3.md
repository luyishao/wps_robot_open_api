# Webhook URL 格式变更说明 (v3.0 - 已废弃)

## ⚠️ 重要提示：本版本已废弃

**当前版本**: v4.0 (2026-01-30)  
**当前格式**: `/at_robot/{username}/{robot_name}`  
**详细说明**: 请查看 [WEBHOOK_URL_CHANGE_V4.md](WEBHOOK_URL_CHANGE_V4.md)

---

**以下内容为历史记录，仅供参考**

---

## 版本历史

### v3.0 (2026-01-30) - ❌ 已废弃

**新格式**:
```
/xz_robot/{username}/{robot_name}
```

**示例**:
```
http://your-domain.com/xz_robot/admin/myrobot
```

**变更原因**:
- 增加统一的前缀 `xz_robot`，便于识别和管理
- 提高URL的可读性和语义化
- 便于在Nginx等反向代理中进行路由配置

---

### v2.2 (之前版本)

**旧格式**:
```
/callback/{username}/{robot_name}
```

**示例**:
```
http://your-domain.com/callback/admin/myrobot
```

**状态**: ❌ 已废弃

---

## 迁移指南

### 如果您正在使用旧版本

1. **更新WPS机器人配置**
   - 登录WPS开放平台
   - 找到您的机器人配置
   - 将webhook URL从 `/callback/...` 更新为 `/xz_robot/...`

2. **示例对比**

   **旧URL**:
   ```
   http://example.com/callback/admin/my_robot
   ```

   **新URL**:
   ```
   http://example.com/xz_robot/admin/my_robot
   ```

3. **测试新URL**
   ```bash
   # GET请求测试
   curl http://your-domain.com/xz_robot/admin/myrobot
   
   # 应返回: {"result":"ok"}
   ```

4. **注意事项**
   - 新旧URL不兼容，必须完全替换
   - 建议先在测试环境验证
   - 更新后需要在WPS平台重新验证webhook地址

---

## 获取正确的Webhook URL

### 方法1: 通过Web界面

1. 登录系统
2. 进入机器人详情页
3. 复制显示的"Webhook回调地址"
4. 完整URL格式: `http://your-domain:port/xz_robot/username/robot_name`

### 方法2: 通过代码

```python
from robots.models import Robot

# 获取机器人
robot = Robot.objects.get(id=your_robot_id)

# 获取webhook URL（相对路径）
webhook_url = robot.get_webhook_callback_url()
print(webhook_url)  # /xz_robot/username/robot_name

# 完整URL
full_url = f"http://your-domain:8080{webhook_url}"
```

---

## URL结构说明

```
http://your-domain.com/xz_robot/{username}/{robot_name}
          ↓                ↓         ↓          ↓
       域名部分         固定前缀   用户名    机器人名称
```

**各部分说明**:

1. **域名**: 您的服务器域名或IP地址
2. **xz_robot**: 固定前缀（必需）
3. **username**: 机器人所有者的用户名
4. **robot_name**: 机器人名称（同一用户下唯一）

---

## 技术细节

### URL路由配置

**文件**: `robots/urls.py`

```python
path('xz_robot/<str:username>/<str:robot_name>', 
     views.webhook_callback, 
     name='webhook_callback'),
```

### 模型方法

**文件**: `robots/models.py`

```python
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址（相对路径）"""
    return f"/xz_robot/{self.owner.username}/{self.name}"
```

---

## 常见问题

### Q1: 为什么要改变URL格式？

A: 主要原因：
- 更语义化的URL路径
- 便于在反向代理中配置
- 统一的前缀便于识别和管理
- 提高系统的可扩展性

### Q2: 旧的URL还能用吗？

A: 不能。新版本已完全移除对旧URL格式的支持，必须使用新格式。

### Q3: 如何快速迁移？

A: 
1. 在系统中找到所有机器人的webhook URL
2. 将 `/callback/` 替换为 `/xz_robot/`
3. 在WPS平台更新webhook配置
4. 测试验证

### Q4: 如果忘记更新会怎样？

A: WPS将无法正常发送消息到webhook，会收到404错误。

---

## 测试验证

### 验证步骤

1. **GET请求验证**
   ```bash
   curl http://your-domain:8080/xz_robot/admin/test
   ```
   
   预期返回:
   ```json
   {"result":"ok"}
   ```

2. **POST请求验证**
   ```bash
   curl -X POST http://your-domain:8080/xz_robot/admin/test \
        -H "Content-Type: application/json" \
        -d '{"msgtype":"text","text":{"content":"test"}}'
   ```
   
   预期返回:
   ```json
   {"result":"ok"}
   ```

### 在WPS平台验证

1. 登录WPS开放平台
2. 进入机器人配置
3. 输入新的webhook URL
4. 点击"验证"按钮
5. 应该显示验证成功

---

## 相关文档

- [README.md](../README.md) - 项目说明
- [快速开始.md](快速开始.md) - 快速入门
- [WEBHOOK_TEST_GUIDE.md](WEBHOOK_TEST_GUIDE.md) - Webhook测试指南

---

**更新时间**: 2026-01-30  
**版本**: v3.0
