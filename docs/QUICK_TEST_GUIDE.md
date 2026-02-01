# 🧪 卡片消息快速测试指南

## 问题已修复 ✅

**修复内容**：
1. ✅ 正确解析包含完整结构的JSON（msgtype + card）
2. ✅ 支持只提供card内容的JSON（自动添加msgtype）
3. ✅ 改进表单输入自动构造WPS标准格式
4. ✅ 更详细的错误提示

## 📋 测试步骤

### 测试1：使用完整JSON（推荐）

1. 登录系统：http://127.0.0.1:8080/
2. 进入机器人详情页
3. 点击"发送消息"
4. 选择"卡片消息"
5. 在"消息内容"框中粘贴以下JSON：

```json
{
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
          "text": "这是测试内容"
        }
      }
    ]
  }
}
```

6. 点击"发送消息"
7. 检查是否发送成功

### 测试2：使用card_message_case.json

1. 打开 `card_message_case.json` 文件
2. 复制整个JSON内容
3. 在发送消息页面，选择"卡片消息"
4. 粘贴JSON到"消息内容"框
5. 点击"发送消息"
6. 应该成功发送完整的国际化卡片

### 测试3：使用简化JSON

只提供card内容，系统自动添加msgtype：

```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "简化格式测试"
      }
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {
        "type": "markdown",
        "text": "**加粗文本**\n\n普通文本"
      }
    }
  ]
}
```

### 测试4：使用表单字段

1. 选择"卡片消息"
2. 在"卡片标题"框输入：`表单测试`
3. 在"卡片内容"框输入：`这是通过表单发送的卡片`
4. 点击"发送消息"
5. 系统会自动构造WPS标准格式

## 🔍 验证结果

### 成功标志
- ✅ 看到"消息发送成功"提示
- ✅ 在消息列表中看到新记录
- ✅ 消息状态显示"成功"
- ✅ WPS机器人收到卡片消息

### 失败排查
如果看到错误：

1. **JSON格式错误**
   - 检查JSON是否有效（使用jsonlint.com验证）
   - 确认使用双引号，不是单引号
   - 检查是否有多余的逗号

2. **HTTP 400错误**
   - 查看错误消息详情
   - 检查卡片结构是否符合WPS要求
   - 确认header或elements有内容

3. **网络错误**
   - 检查Webhook URL是否正确
   - 确认WPS机器人地址可访问

## 📊 JSON格式对比

### ❌ 旧格式（不支持）
```json
{
  "msgtype": "card",
  "card": {
    "title": "标题",
    "text": "内容"
  }
}
```

### ✅ 新格式（WPS标准）
```json
{
  "msgtype": "card",
  "card": {
    "header": {
      "title": {
        "tag": "text",
        "content": {
          "type": "plainText",
          "text": "标题"
        }
      }
    },
    "elements": [
      {
        "tag": "text",
        "content": {
          "type": "plainText",
          "text": "内容"
        }
      }
    ]
  }
}
```

## 🎯 预期输出

发送成功后，在消息记录中应该看到：

```json
{
  "msgtype": "card",
  "card": {
    "header": {...},
    "elements": [...],
    "i18n": {...}  // 如果提供了国际化内容
  }
}
```

## 📝 注意事项

1. **JSON必须有效**：使用在线工具验证JSON格式
2. **编码问题**：确保使用UTF-8编码
3. **字段完整**：至少包含header或elements
4. **类型正确**：type可以是plainText或markdown

## 🆘 问题反馈

如果测试仍然失败，请提供：
1. 完整的错误消息
2. 使用的JSON内容
3. 服务器日志（如有）

---

**测试时间**: 2026-01-30
**版本**: v2.0
**状态**: 已修复 ✅
