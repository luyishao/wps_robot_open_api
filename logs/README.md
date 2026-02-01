# 日志文件目录

此目录用于存储项目运行日志。

## 日志文件

- `django.log` - Django主日志（INFO及以上级别）
- `error.log` - 错误日志（仅ERROR级别）
- `webhook.log` - Webhook专用日志（详细的webhook请求和响应）

## 日志轮转

- 单个文件最大：10MB
- 保留备份：5-10个文件
- 备份文件格式：`filename.log.1`, `filename.log.2` 等

## 查看日志

### Windows
```batch
.\view_logs.bat
```

### Linux/MacOS
```bash
./logs.sh
```

## 注意事项

- 日志文件已添加到 `.gitignore`，不会提交到版本控制
- 建议定期清理30天前的旧日志
- 日志可能包含敏感信息，请妥善保管

详细说明请查看：[LOGS_GUIDE.md](../docs/LOGS_GUIDE.md)
