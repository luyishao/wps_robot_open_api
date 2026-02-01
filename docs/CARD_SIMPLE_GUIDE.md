# 🎯 卡片消息使用指南（简化版）

## ✨ 简化说明

**重要变更**：现在发送卡片消息时，**只需要输入card部分的JSON**，系统会自动添加`msgtype`字段。

### 输入格式

❌ **不需要**完整格式：
```json
{
  "msgtype": "card",
  "card": {
    ...
  }
}
```

✅ **只需要**card内容：
```json
{
  "header": {
    ...
  },
  "elements": [
    ...
  ]
}
```

系统会自动构造为：
```json
{
  "msgtype": "card",
  "card": {你输入的JSON}
}
```

---

## 📋 快速测试

### 测试1：使用card_message_case.json

直接复制 `card_message_case.json` 中**card部分**的内容：

```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "标题"
      }
    },
    "subtitle": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "副标题"
      }
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {
        "type": "markdown",
        "text": "普通文本"
      }
    }
  ],
  "i18n": {
    "zh-TW": {
      "header": {
        "title": {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "標題"
          }
        },
        "subtitle": {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "副標題"
          }
        }
      },
      "elements": [
        {
          "tag": "text",
          "content": {
            "type": "markdown",
            "text": "普通文本"
          }
        }
      ]
    },
    "en-US": {
      "header": {
        "title": {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "title"
          }
        },
        "subtitle": {
          "tag": "text",
          "content": {
            "type": "plainText",
            "text": "sub title"
          }
        }
      },
      "elements": [
        {
          "tag": "text",
          "content": {
            "type": "markdown",
            "text": "common text"
          }
        }
      ]
    }
  }
}
```

### 测试2：简单卡片

```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "测试标题"
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
```

### 测试3：带Markdown的卡片

```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {
        "type": "plainText",
        "text": "通知"
      }
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {
        "type": "markdown",
        "text": "**重要通知**\n\n系统将于今晚进行维护"
      }
    }
  ]
}
```

---

## 🎓 使用步骤

### 步骤1：准备JSON
从以下位置获取card的JSON：
- 复制`card_message_case.json`中`"card"`字段的值
- 使用上面的测试用例
- 按WPS格式自己编写

### 步骤2：发送消息
1. 登录系统：http://127.0.0.1:8080/
2. 进入机器人详情页
3. 点击"发送消息"
4. 消息类型选择"卡片消息"
5. 在"消息内容"框粘贴JSON（只要card部分）
6. 点击"发送消息"

### 步骤3：验证结果
- 看到"消息发送成功"
- 在消息列表中查看发送记录
- WPS机器人收到卡片消息

---

## 📝 JSON格式说明

### 必需字段

至少包含以下之一：
- `header`: 卡片头部
- `elements`: 卡片内容元素

### 推荐结构

```json
{
  "header": {
    "title": {...},        // 标题（推荐）
    "subtitle": {...}      // 副标题（可选）
  },
  "elements": [            // 内容元素数组
    {...}
  ],
  "i18n": {                // 国际化（可选）
    "zh-TW": {...},
    "en-US": {...}
  }
}
```

### 内容类型

**plainText**（纯文本）：
```json
{
  "tag": "text",
  "content": {
    "type": "plainText",
    "text": "这是纯文本"
  }
}
```

**markdown**（格式化文本）：
```json
{
  "tag": "text",
  "content": {
    "type": "markdown",
    "text": "**加粗** *斜体* [链接](url)"
  }
}
```

---

## ⚡ 从card_message_case.json提取card部分

如果你有完整的JSON文件：

```json
{
  "msgtype": "card",
  "card": {
    // 👈 只复制这里面的内容
    "header": {...},
    "elements": [...],
    "i18n": {...}
  }
}
```

**操作**：
1. 打开`card_message_case.json`
2. 找到`"card"`字段
3. 复制`"card": {` 和 `}` 之间的内容（包括大括号）
4. 粘贴到发送消息框

---

## 🔧 表单输入方式

如果不想写JSON，可以使用表单字段：

**输入**：
- 卡片标题：`欢迎使用`
- 卡片内容：`感谢您使用WPS机器人`

**系统自动构造为**：
```json
{
  "msgtype": "card",
  "card": {
    "header": {
      "title": {
        "tag": "text",
        "content": {
          "type": "plainText",
          "text": "欢迎使用"
        }
      }
    },
    "elements": [
      {
        "tag": "text",
        "content": {
          "type": "plainText",
          "text": "感谢您使用WPS机器人"
        }
      }
    ]
  }
}
```

---

## ⚠️ 注意事项

1. **JSON格式**：
   - 使用双引号`"`，不能用单引号`'`
   - 最后一项不要加逗号
   - 可以用jsonlint.com验证格式

2. **不要包含msgtype**：
   - ❌ 不要写 `"msgtype": "card"`
   - ❌ 不要在最外层包`"card": {}`
   - ✅ 直接写card的内容

3. **必需内容**：
   - 至少要有`header`或`elements`
   - `header.title`是推荐包含的

---

## 🎉 示例对比

### ❌ 错误示例（会被double包装）
```json
{
  "msgtype": "card",
  "card": {
    "header": {...}
  }
}
```
会变成：
```json
{
  "msgtype": "card",
  "card": {
    "msgtype": "card",  // ❌ 嵌套错误
    "card": {...}
  }
}
```

### ✅ 正确示例
```json
{
  "header": {
    "title": {
      "tag": "text",
      "content": {"type": "plainText", "text": "标题"}
    }
  },
  "elements": [...]
}
```
会变成：
```json
{
  "msgtype": "card",
  "card": {
    "header": {...},  // ✅ 正确
    "elements": [...]
  }
}
```

---

## 📚 更多信息

详细文档请参考：
- `CARD_MESSAGE_TEST.md` - 完整测试用例
- `card_message_case.json` - 标准测试数据

---

**更新日期**: 2026-01-30  
**版本**: v2.1（简化版）  
**重要提示**: 只需输入card的JSON内容，系统会自动添加msgtype ✨
