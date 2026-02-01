# 🔧 Hook脚本设置问题排查指南

## 📋 问题分析

根据日志显示，多次POST请求到`/robots/1/edit/`返回200，但可能没有成功保存设置。

## 🔍 常见问题和解决方案

### 问题1：Hook脚本名称错误

**症状**：设置预设脚本名称后，webhook收到消息时没有执行hook

**原因**：
- 输入的脚本名称不正确
- 脚本文件不存在

**可用的预设脚本名称**：
1. `echo_hook` - 简单回显消息
2. `example_hook` - 示例脚本（带转发功能）

**正确设置方法**：
在"Hook脚本"字段中输入：
```
echo_hook
```
或
```
example_hook
```

**注意**：
- ❌ 不要加 `.py` 后缀
- ❌ 不要加路径
- ✅ 只输入脚本名称（不含扩展名）

---

### 问题2：上传的Python脚本函数名错误

**症状**：上传了.py文件，但webhook回调时报错

**原因**：脚本中没有`process_message`函数或函数签名不正确

**正确的脚本格式**：
```python
def process_message(robot, message_data):
    """
    处理webhook接收到的消息
    
    参数：
        robot: 机器人对象（Robot模型实例）
        message_data: webhook POST的数据（字典格式）
    
    返回：
        dict: 要返回给WPS的响应数据（可选，返回None则使用默认响应）
    """
    # 你的处理逻辑
    print(f"收到消息: {message_data}")
    
    # 可选：返回自定义响应
    return {
        "result": "ok",
        "custom_field": "value"
    }
```

**关键点**：
- ✅ 函数名必须是 `process_message`
- ✅ 必须接受两个参数：`robot` 和 `message_data`
- ✅ 可以返回dict（自定义响应）或None（默认响应）

---

### 问题3：文件上传大小超限

**症状**：上传.py文件时显示错误

**原因**：文件大小超过1MB

**解决方案**：
- 检查文件大小：必须 ≤ 1MB
- 精简脚本内容
- 移除不必要的注释和空行

---

### 问题4：脚本文件格式错误

**症状**：上传文件时提示格式错误

**原因**：上传的不是.py文件

**解决方案**：
- ✅ 只能上传 `.py` 文件
- ❌ 不能上传 `.txt`、`.doc` 等其他格式

---

### 问题5：表单验证失败

**症状**：点击保存后页面没有跳转，显示错误信息

**可能原因**：
1. 必填字段未填写
2. Webhook URL格式不正确
3. 消息记录数超出范围（1-1000）

**检查清单**：
- [ ] 机器人名称已填写
- [ ] Webhook URL格式正确（http://或https://开头）
- [ ] 消息记录数在1-1000之间
- [ ] Hook脚本名称正确（如果填写了）
- [ ] 上传的文件是.py格式且≤1MB（如果上传了）

---

## 🎯 完整设置步骤

### 方式1：使用预设Hook脚本

1. **进入机器人编辑页面**
   - 访问 http://127.0.0.1:8080/robots/
   - 点击要设置的机器人
   - 点击"编辑"按钮

2. **设置Hook脚本字段**
   ```
   echo_hook
   ```
   或
   ```
   example_hook
   ```

3. **不要上传文件**
   - Hook脚本文件字段留空

4. **保存**
   - 点击"保存"按钮
   - 应该跳转回机器人详情页

5. **验证**
   - 发送POST请求测试webhook
   - 检查消息记录中的响应数据

---

### 方式2：上传自定义Hook脚本

1. **准备脚本文件**
   
   创建文件 `my_hook.py`：
   ```python
   def process_message(robot, message_data):
       """处理消息"""
       msg_type = message_data.get('msgtype', '')
       
       if msg_type == 'text':
           content = message_data.get('text', {}).get('content', '')
           print(f"收到文本: {content}")
           
           return {
               "result": "ok",
               "echo": content
           }
       
       return None  # 使用默认响应
   ```

2. **进入机器人编辑页面**

3. **上传脚本文件**
   - 点击"Hook脚本文件"的"选择文件"按钮
   - 选择你的 `my_hook.py` 文件
   - 确认文件名显示在按钮旁边

4. **Hook脚本字段留空**
   - 如果同时设置了两个，优先使用上传的文件

5. **保存并验证**

---

## 🧪 测试Hook脚本

### 测试步骤

1. **设置hook脚本**（使用上述任一方式）

2. **发送测试消息**
   ```powershell
   $body = '{"msgtype":"text","text":{"content":"测试hook"}}'
   Invoke-WebRequest -Uri "http://127.0.0.1:8080/callback/admin/test" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
   ```

3. **查看响应**
   - 如果hook正常工作，应该返回自定义响应
   - 如果没有hook或hook返回None，返回 `{"result":"ok"}`

4. **查看消息记录**
   - 进入机器人详情页
   - 查看消息列表
   - 检查最新消息的"响应数据"字段

---

## 🐛 调试技巧

### 1. 查看服务器日志

如果hook脚本中有`print`语句，会输出到服务器终端：

```python
def process_message(robot, message_data):
    print(f"[DEBUG] 机器人: {robot.name}")
    print(f"[DEBUG] 消息: {message_data}")
    # ...
```

查看日志：
- 在运行Django服务器的终端窗口查看
- 或读取终端文件

### 2. 检查消息记录

进入机器人详情页 → 消息列表 → 查看最新消息：
- **状态**：应该是"成功"
- **响应数据**：查看hook返回的内容
- **错误信息**：如果失败，查看具体错误

### 3. 测试脚本语法

在上传前，本地测试脚本：

```python
# 测试脚本
import sys

# 模拟robot对象
class MockRobot:
    name = "test"
    webhook_url = ""

# 模拟message_data
test_data = {
    "msgtype": "text",
    "text": {
        "content": "测试消息"
    }
}

# 导入并测试
from my_hook import process_message
result = process_message(MockRobot(), test_data)
print(f"返回结果: {result}")
```

---

## 📝 Hook脚本示例

### 示例1：简单回显（echo_hook.py）

```python
def process_message(robot, message_data):
    """回显消息"""
    msg_type = message_data.get('msgtype', '')
    
    if msg_type == 'text':
        content = message_data.get('text', {}).get('content', '')
        return {
            "result": "ok",
            "echo": f"您说: {content}"
        }
    
    return None
```

### 示例2：关键词自动回复

```python
def process_message(robot, message_data):
    """关键词自动回复"""
    msg_type = message_data.get('msgtype', '')
    
    if msg_type == 'text':
        content = message_data.get('text', {}).get('content', '').lower()
        
        # 关键词匹配
        if '你好' in content or 'hello' in content:
            return {
                "result": "ok",
                "reply": "你好！有什么可以帮助您的吗？"
            }
        elif '帮助' in content or 'help' in content:
            return {
                "result": "ok",
                "reply": "这是帮助信息..."
            }
    
    return None  # 默认响应
```

### 示例3：消息转发

```python
import requests

def process_message(robot, message_data):
    """转发消息到其他系统"""
    try:
        # 转发到其他API
        response = requests.post(
            'https://your-api.com/webhook',
            json=message_data,
            timeout=5
        )
        
        return {
            "result": "ok",
            "forwarded": True,
            "status": response.status_code
        }
    except Exception as e:
        return {
            "result": "ok",
            "forwarded": False,
            "error": str(e)
        }
```

### 示例4：数据库记录

```python
from datetime import datetime

def process_message(robot, message_data):
    """记录消息到数据库（示例）"""
    msg_type = message_data.get('msgtype', '')
    
    # 注意：在实际的Django环境中可以使用ORM
    # 这里只是示例逻辑
    
    log_data = {
        'robot': robot.name,
        'type': msg_type,
        'time': datetime.now().isoformat(),
        'data': message_data
    }
    
    print(f"[LOG] {log_data}")
    
    # 可以在这里保存到数据库
    # YourModel.objects.create(...)
    
    return None
```

---

## ⚠️ 常见错误信息

### 错误1：`ModuleNotFoundError: No module named 'xxx_hook'`

**原因**：Hook脚本名称错误或文件不存在

**解决**：
- 检查脚本名称拼写
- 确认脚本文件在 `robots/hooks/` 目录下
- 使用正确的脚本名：`echo_hook` 或 `example_hook`

---

### 错误2：`AttributeError: module 'xxx_hook' has no attribute 'process_message'`

**原因**：脚本中没有定义 `process_message` 函数

**解决**：
- 在脚本中添加 `process_message` 函数
- 检查函数名拼写（注意下划线）

---

### 错误3：`TypeError: process_message() takes X positional arguments but Y were given`

**原因**：`process_message` 函数的参数数量不正确

**解决**：
- 确保函数定义为：`def process_message(robot, message_data):`
- 必须有两个参数

---

## 🎯 快速排查清单

遇到hook设置问题时，按顺序检查：

- [ ] 1. 机器人是否已保存成功？
- [ ] 2. Hook脚本名称是否正确？（不含.py后缀）
- [ ] 3. 上传的文件是否≤1MB？
- [ ] 4. 上传的文件扩展名是否为.py？
- [ ] 5. 脚本中是否有`process_message`函数？
- [ ] 6. 函数签名是否正确（两个参数）？
- [ ] 7. Webhook URL是否正确配置？
- [ ] 8. 发送测试消息时是否收到响应？
- [ ] 9. 查看消息记录中是否有错误信息？
- [ ] 10. 服务器日志中是否有错误输出？

---

## 💡 最佳实践

1. **先使用预设脚本**
   - 使用 `echo_hook` 验证基本功能
   - 确认hook机制正常工作

2. **逐步开发自定义脚本**
   - 从简单的脚本开始
   - 添加print调试信息
   - 本地测试后再上传

3. **错误处理**
   - 在hook脚本中添加try-except
   - 返回有意义的错误信息

4. **性能考虑**
   - Hook脚本应该快速执行（<3秒）
   - 避免阻塞操作
   - 长时间任务考虑异步处理

---

**如果问题仍然存在**，请提供：
1. 完整的错误信息（截图或文字）
2. 您使用的脚本名称或上传的文件内容
3. 机器人编辑页面的截图
4. 服务器日志中的相关错误信息

我会帮您进一步诊断问题！
