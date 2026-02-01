# ✅ Webhook回调地址显示问题已修复

## 🐛 问题描述

**症状**：Webhook回调地址显示重复
```
错误显示: http://127.0.0.1:8080http://127.0.0.1:8080/admin/test
正确显示: http://127.0.0.1:8080/admin/test
```

## 🔍 原因分析

在`robot_detail.html`模板中，URL的构造方式是：
```django
{{ request.scheme }}://{{ request.get_host }}{{ webhook_callback_url }}
```

但是`Robot.get_webhook_callback_url(request)`方法在传入request时，使用了`request.build_absolute_uri()`，这会返回完整的URL（包括协议和域名），导致在模板中重复拼接。

**问题代码**：
```python
def get_webhook_callback_url(self, request=None):
    if request:
        return request.build_absolute_uri(f'/{self.owner.username}/{self.name}')
        # ↑ 返回 http://127.0.0.1:8080/admin/test
    return f"/{self.owner.username}/{self.name}"
```

**模板代码**：
```django
{{ request.scheme }}://{{ request.get_host }}{{ webhook_callback_url }}
                                             ↑ 已经是完整URL了，导致重复
```

## ✅ 修复方案

修改`Robot.get_webhook_callback_url()`方法，始终返回相对路径：

```python
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址（相对路径）"""
    return f"/{self.owner.username}/{self.name}"
```

这样模板可以灵活地构造完整URL或使用相对路径。

## 📝 修改文件

**文件**: `robots/models.py`

**修改前**：
```python
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址"""
    if request:
        return request.build_absolute_uri(f'/{self.owner.username}/{self.name}')
    return f"/{self.owner.username}/{self.name}"
```

**修改后**：
```python
def get_webhook_callback_url(self, request=None):
    """获取webhook回调地址（相对路径）"""
    return f"/{self.owner.username}/{self.name}"
```

## 🧪 验证结果

修复后，Webhook回调地址应该正确显示为：
```
http://127.0.0.1:8080/admin/test
```

或在生产环境：
```
https://yourdomain.com/username/robotname
```

## 📋 测试步骤

1. 访问 http://127.0.0.1:8080/
2. 登录系统（admin/admin123456）
3. 进入任意机器人详情页
4. 查看"Webhook回调地址"
5. 确认格式正确，无重复域名

**预期结果**：
```
http://127.0.0.1:8080/用户名/机器人名称
```

## 💡 设计说明

### 职责分离

- **模型方法**：返回相对路径（`/username/robotname`）
- **模板层**：根据需要构造完整URL

这样的设计更加灵活：

1. **在模板中显示完整URL**：
   ```django
   {{ request.scheme }}://{{ request.get_host }}{{ webhook_callback_url }}
   ```

2. **只显示路径**：
   ```django
   {{ webhook_callback_url }}
   ```

3. **在视图中构造完整URL**：
   ```python
   full_url = request.build_absolute_uri(robot.get_webhook_callback_url())
   ```

## 🎯 影响范围

### 受影响的文件
- ✅ `robots/models.py` - 已修复
- ✅ `robots/templates/robots/robot_detail.html` - 正常工作

### 不受影响的功能
- ✅ Webhook接收功能（URL路由）
- ✅ 消息发送功能
- ✅ 其他页面显示

## 🔄 自动重载

Django开发服务器已自动重新加载，无需手动重启。

---

**修复时间**: 2026-01-30  
**状态**: ✅ 已修复  
**影响**: 仅显示问题，不影响功能
