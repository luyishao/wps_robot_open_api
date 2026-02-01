# 测试文件说明

本目录包含测试数据和示例文件。

## 卡片消息测试文件

### card_simple_test.json
简单的卡片消息测试用例，包含基本的标题和内容。

**用途**：
- 快速测试卡片消息功能
- 学习卡片消息的基本结构

**使用方法**：
1. 在发送消息页面选择"卡片消息"
2. 复制此文件内容到消息内容框
3. 点击发送

### card_only.json
完整的卡片消息示例，包含国际化支持。

**特点**：
- 包含中英文双语标题
- 支持国际化配置
- 展示完整的卡片结构

**使用方法**：
同 card_simple_test.json

### card_message_case.json
卡片消息的各种使用案例集合。

**包含内容**：
- 不同类型的卡片布局
- 多种元素组合
- 复杂的卡片示例

## 如何使用测试文件

### 方法1：通过Web界面
1. 登录系统
2. 进入机器人详情页
3. 点击"发送消息"
4. 选择消息类型为"卡片消息"
5. 复制测试文件中的JSON内容
6. 粘贴到"消息内容"框
7. 点击"发送消息"

### 方法2：通过API测试
```python
import requests
import json

# 读取测试文件
with open('tests/card_simple_test.json', 'r', encoding='utf-8') as f:
    card_data = json.load(f)

# 构造完整消息
message = {
    "msgtype": "card",
    "card": card_data
}

# 发送到webhook
webhook_url = "https://your-wps-webhook-url"
response = requests.post(webhook_url, json=message)
print(response.json())
```

### 方法3：直接复制到WPS
如果您在WPS开放平台的测试工具中测试，可以直接复制完整的JSON内容。

## 文件格式说明

所有测试文件都是标准的JSON格式，遵循WPS卡片消息规范。

### 基本结构
```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "卡片标题"
      }
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "卡片内容"
      }
    }
  ]
}
```

## 添加自己的测试文件

您可以在此目录添加自己的测试文件：

1. 创建新的 JSON 文件
2. 遵循WPS卡片消息格式
3. 使用有意义的文件名
4. 建议添加注释说明用途

## 相关文档

- [卡片消息使用指南](../docs/CARD_USAGE.md)
- [卡片消息简明指南](../docs/CARD_SIMPLE_GUIDE.md)
- [卡片消息测试文档](../docs/CARD_MESSAGE_TEST.md)
- [WPS开放平台文档](https://365.kdocs.cn/3rd/open/documents/app-integration-dev/guide/robot/webhook)

## 注意事项

1. **JSON格式**
   - 确保JSON格式正确（可使用在线JSON验证工具）
   - 注意中文编码（使用UTF-8）
   - 不要包含注释（标准JSON不支持注释）

2. **卡片元素**
   - 不同的元素类型有不同的结构要求
   - 参考WPS官方文档了解所有支持的元素
   - 测试前先在WPS测试工具验证

3. **文件大小**
   - 保持测试文件简洁
   - 复杂的卡片可以分成多个测试文件
   - 建议每个文件专注于一种场景

## 贡献测试用例

如果您有好的测试用例，欢迎添加到这个目录！

要求：
- 文件命名清晰明确
- JSON格式正确
- 可以正常工作
- （可选）添加说明文档
