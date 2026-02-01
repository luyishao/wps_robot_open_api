# 🔧 机器人无法保存问题修复说明

## 🐛 问题原因

**根本原因**：表单模板 `robot_form.html` 存在两个关键问题：

### 问题1：缺少 `enctype="multipart/form-data"`

**影响**：无法上传文件（hook_script_file）

**原代码**：
```html
<form method="post">
```

**修复后**：
```html
<form method="post" enctype="multipart/form-data">
```

**说明**：
- 当表单包含文件上传字段时，必须添加 `enctype="multipart/form-data"`
- 没有这个属性，`request.FILES` 将为空
- Django无法接收上传的文件

### 问题2：缺少新增字段

**缺少的字段**：
1. `hook_script_file` - Hook脚本文件上传
2. `max_message_count` - 最大消息记录数

**影响**：
- 这些字段在模型和表单中定义了
- 但在HTML模板中没有显示
- 用户无法设置这些值
- 可能导致表单验证失败

## ✅ 修复内容

### 修复1：添加 enctype 属性

**文件**：`robots/templates/robots/robot_form.html`

**修改**：
```html
<form method="post" enctype="multipart/form-data">
    {% csrf_token %}
    ...
</form>
```

### 修复2：添加 Hook脚本文件上传字段

```html
<div class="mb-3">
    <label for="{{ form.hook_script_file.id_for_label }}" class="form-label">
        Hook脚本文件（上传）
    </label>
    {{ form.hook_script_file }}
    {% if form.hook_script_file.errors %}
    <div class="text-danger">{{ form.hook_script_file.errors }}</div>
    {% endif %}
    <small class="form-text text-muted">
        上传自定义Python脚本文件（.py格式，最大1MB）。如果上传了文件，将优先使用上传的脚本。
    </small>
    {% if robot and robot.hook_script_file %}
    <div class="mt-2">
        <small class="text-success">
            <i class="bi bi-check-circle"></i> 当前文件: {{ robot.hook_script_file.name }}
        </small>
    </div>
    {% endif %}
</div>
```

### 修复3：添加最大消息记录数字段

```html
<div class="mb-3">
    <label for="{{ form.max_message_count.id_for_label }}" class="form-label">
        最大消息记录数
    </label>
    {{ form.max_message_count }}
    {% if form.max_message_count.errors %}
    <div class="text-danger">{{ form.max_message_count.errors }}</div>
    {% endif %}
    <small class="form-text text-muted">
        保留的最大消息数量（1-1000），默认100。超过限制时自动删除旧消息。
    </small>
</div>
```

### 修复4：添加错误提示显示

在表单顶部添加总体错误提示：

```html
{% if form.errors %}
<div class="alert alert-danger">
    <h5>表单验证错误：</h5>
    <ul>
        {% for field, errors in form.errors.items %}
            {% for error in errors %}
                <li><strong>{{ field }}:</strong> {{ error }}</li>
            {% endfor %}
        {% endfor %}
    </ul>
</div>
{% endif %}
```

## 🧪 测试验证

### 测试1：创建/编辑机器人

1. **访问编辑页面**
   ```
   http://127.0.0.1:8080/robots/1/edit/
   ```

2. **填写必填字段**
   - 机器人名称：test
   - Webhook URL：https://example.com/webhook

3. **设置Hook脚本（两种方式任选一种）**

   **方式A：使用预设脚本**
   - Hook脚本（预设）：`echo_hook`
   - Hook脚本文件（上传）：留空

   **方式B：上传自定义脚本**
   - Hook脚本（预设）：留空
   - Hook脚本文件（上传）：选择 .py 文件

4. **设置消息记录数**
   - 最大消息记录数：100（或1-1000之间的任意值）

5. **点击保存**

**预期结果**：
- ✅ 页面跳转到机器人详情页
- ✅ 显示"机器人 'xxx' 更新成功"的提示
- ✅ 可以看到设置的hook脚本和消息记录数

### 测试2：文件上传验证

创建测试脚本 `test_hook.py`：

```python
def process_message(robot, message_data):
    """测试脚本"""
    print(f"[TEST] 机器人: {robot.name}")
    print(f"[TEST] 消息: {message_data}")
    
    return {
        "result": "ok",
        "test": "自定义脚本已执行"
    }
```

**上传步骤**：
1. 编辑机器人
2. 点击"Hook脚本文件"的"选择文件"
3. 选择 `test_hook.py`
4. 保存

**验证**：
- 详情页应该显示上传的文件名
- 发送webhook测试消息，检查是否执行了自定义脚本

### 测试3：表单验证

**测试非法值**：

1. **消息记录数 = 0**（应该失败）
   - 预期：显示错误"消息记录数必须在1到1000之间"

2. **消息记录数 = 1001**（应该失败）
   - 预期：显示错误"消息记录数必须在1到1000之间"

3. **上传非.py文件**（应该失败）
   - 预期：显示错误"只能上传.py文件"

4. **上传超过1MB的文件**（应该失败）
   - 预期：显示错误"文件大小不能超过1MB"

## 📋 完整表单字段列表

修复后，表单包含以下所有字段：

| 字段名 | 类型 | 必填 | 说明 |
|-------|------|------|------|
| name | 文本 | ✅ | 机器人名称 |
| webhook_url | URL | ❌ | WPS机器人的webhook地址 |
| description | 文本域 | ❌ | 机器人描述 |
| hook_script | 文本 | ❌ | 预设脚本名称（如echo_hook） |
| hook_script_file | 文件 | ❌ | 上传的Python脚本文件 |
| max_message_count | 数字 | ✅ | 最大消息记录数（默认100） |
| is_active | 复选框 | ❌ | 是否启用（默认启用） |

## 🎯 使用指南

### 设置Hook脚本的三种方式

#### 方式1：不使用Hook脚本
- Hook脚本（预设）：留空
- Hook脚本文件（上传）：不选择文件
- **结果**：webhook只记录消息，返回默认响应

#### 方式2：使用预设脚本
- Hook脚本（预设）：`echo_hook` 或 `example_hook`
- Hook脚本文件（上传）：不选择文件
- **结果**：使用系统预设的脚本处理消息

**可用的预设脚本**：
- `echo_hook` - 简单回显消息
- `example_hook` - 带转发功能的示例脚本

#### 方式3：上传自定义脚本（推荐）
- Hook脚本（预设）：留空
- Hook脚本文件（上传）：选择你的 .py 文件
- **结果**：使用你上传的自定义脚本

**优先级**：上传的文件 > 预设脚本

### 自定义脚本模板

```python
def process_message(robot, message_data):
    """
    处理webhook消息
    
    参数：
        robot: Robot模型实例，包含机器人配置信息
        message_data: dict，WPS发送的消息数据
    
    返回：
        dict: 自定义响应数据（可选）
        None: 使用默认响应 {"result":"ok"}
    """
    # 获取消息类型
    msg_type = message_data.get('msgtype', '')
    
    # 处理文本消息
    if msg_type == 'text':
        content = message_data.get('text', {}).get('content', '')
        print(f"收到文本: {content}")
        
        # 返回自定义响应
        return {
            "result": "ok",
            "received": content,
            "timestamp": datetime.now().isoformat()
        }
    
    # 处理其他类型消息
    # ...
    
    # 使用默认响应
    return None
```

## 🔍 故障排查

### 问题：点击保存后页面刷新但没有成功提示

**原因**：表单验证失败

**解决**：
1. 查看页面顶部是否有红色错误提示框
2. 检查必填字段是否填写
3. 检查数值字段是否在有效范围内

### 问题：上传文件后还是使用预设脚本

**原因**：表单缺少 `enctype="multipart/form-data"`（已修复）

**验证修复**：
1. 刷新编辑页面（Ctrl+F5 强制刷新）
2. 重新上传文件
3. 保存后查看详情页，确认文件名显示

### 问题：Hook脚本没有执行

**检查清单**：
1. [ ] 机器人状态是否为"启用"
2. [ ] Hook脚本名称是否正确（不含.py）
3. [ ] 上传的脚本是否包含 `process_message` 函数
4. [ ] 函数签名是否正确（两个参数）
5. [ ] 发送测试webhook时机器人名称是否正确

### 问题：修改后看不到变化

**解决**：
1. 强制刷新浏览器（Ctrl+F5）
2. 清除浏览器缓存
3. 检查Django服务器是否自动重载

## 📝 修改文件清单

| 文件 | 修改内容 | 状态 |
|-----|---------|------|
| `robots/templates/robots/robot_form.html` | 添加 enctype 属性 | ✅ 已修复 |
| `robots/templates/robots/robot_form.html` | 添加 hook_script_file 字段 | ✅ 已修复 |
| `robots/templates/robots/robot_form.html` | 添加 max_message_count 字段 | ✅ 已修复 |
| `robots/templates/robots/robot_form.html` | 添加错误提示显示 | ✅ 已修复 |

## 🎉 修复后的功能

现在您可以：

1. ✅ **正常保存机器人设置**
   - 所有字段都能正确保存
   - 表单验证正常工作
   - 保存后正确跳转

2. ✅ **上传自定义Hook脚本**
   - 支持 .py 文件上传
   - 文件大小限制 1MB
   - 自动验证文件格式

3. ✅ **设置消息记录限制**
   - 范围 1-1000
   - 默认值 100
   - 超出自动删除旧消息

4. ✅ **查看详细错误信息**
   - 表单顶部显示总体错误
   - 每个字段下方显示具体错误
   - 错误信息清晰明确

## 🚀 下一步

1. **刷新编辑页面**
   - 访问 http://127.0.0.1:8080/robots/1/edit/
   - 按 Ctrl+F5 强制刷新

2. **重新设置Hook脚本**
   - 方式A：输入 `echo_hook`
   - 方式B：上传自定义 .py 文件

3. **点击保存**
   - 应该成功跳转到详情页
   - 查看hook脚本设置是否生效

4. **测试Hook功能**
   ```powershell
   $body = '{"msgtype":"text","text":{"content":"测试"}}'
   Invoke-WebRequest -Uri "http://127.0.0.1:8080/callback/admin/test" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
   ```

---

**修复时间**：2026-01-30  
**修复版本**：v2.5  
**问题**：机器人设置无法保存  
**状态**：✅ 已完全修复
