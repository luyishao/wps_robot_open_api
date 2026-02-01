# Webhook URL 格式更新总结 (v4.0)

## 📅 更新日期
2026-01-30

## 🎯 更新内容

### URL格式变更
- **旧格式**: `/xz_robot/{username}/{robot_name}`
- **新格式**: `/at_robot/{username}/{robot_name}`

### 变更原因
1. **语义更清晰**: `at_robot` = @ Robot (艾特机器人)，符合"@机器人"的使用场景
2. **命名规范**: 使用通用英文单词，避免拼音缩写(xz)，提高代码可读性
3. **统一风格**: 与行业惯例保持一致，便于国际化扩展

## ✅ 已完成的修改

### 代码文件
1. ✅ `robots/urls.py` - 更新URL路由配置
2. ✅ `robots/models.py` - 更新 `get_webhook_callback_url()` 方法

### 文档文件
1. ✅ `README.md` - 更新Webhook回调地址说明
2. ✅ `QUICK_REFERENCE.md` - 更新快速参考和测试命令
3. ✅ `docs/WPS协作后台机器人Django项目需求.md` - 添加需求变更记录
4. ✅ `docs/DIRECTORY_STRUCTURE.md` - 添加变更通知
5. ✅ `docs/PROJECT_REORGANIZATION_SUMMARY.md` - 更新整理总结
6. ✅ `docs/WEBHOOK_URL_CHANGE_V4.md` - 新增详细变更说明文档

## 📝 迁移指南

### 步骤1: 更新代码
```bash
# 拉取最新代码
git pull

# 或者手动更新两个文件中的 xz_robot 为 at_robot
```

### 步骤2: 重启服务
```bash
# Linux/MacOS
./stop.sh
./start.sh

# Windows
# 停止现有服务，然后运行 shell\启动服务器_venv.bat

# Docker
docker-compose restart
```

### 步骤3: 更新WPS平台配置
1. 登录 WPS 开放平台
2. 进入机器人配置页面
3. 将 Webhook URL 更新为新格式：
   ```
   旧: http://your-domain:8080/xz_robot/用户名/机器人名
   新: http://your-domain:8080/at_robot/用户名/机器人名
   ```

### 步骤4: 验证测试
```bash
# GET请求测试
curl http://your-domain:8080/at_robot/admin/test
# 预期返回: {"result":"ok"}

# POST请求测试
curl -X POST http://your-domain:8080/at_robot/admin/test \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试"}}'
```

## 🔍 检查清单

- [ ] 代码已更新到最新版本
- [ ] 服务已重启
- [ ] WPS平台webhook URL已更新
- [ ] GET请求测试通过
- [ ] POST请求测试通过
- [ ] 能正常接收消息
- [ ] 能正常发送消息
- [ ] 消息记录功能正常

## ⚠️ 重要说明

### 兼容性
- ❌ 旧格式 `/xz_robot/` 不再支持
- ❌ 更旧的格式 `/callback/` 不再支持
- ✅ 必须使用新格式 `/at_robot/`

### 功能不变
- ✅ 支持GET/POST请求
- ✅ 无需登录认证
- ✅ 自动记录消息
- ✅ Hook脚本支持
- ✅ 所有现有功能保持不变

## 📊 版本历史

| 版本 | URL格式 | 状态 | 日期 |
|------|---------|------|------|
| v2.0 | `/callback/{user}/{robot}` | ❌ 已废弃 | - |
| v3.0 | `/xz_robot/{user}/{robot}` | ❌ 已废弃 | 2026-01-30 |
| v4.0 | `/at_robot/{user}/{robot}` | ✅ 当前版本 | 2026-01-30 |

## 📚 相关文档

- [WEBHOOK_URL_CHANGE_V4.md](docs/WEBHOOK_URL_CHANGE_V4.md) - 详细变更说明
- [README.md](README.md) - 项目主文档
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速参考

## 💡 提示

1. 这是一个破坏性变更，旧URL将不再工作
2. 请尽快更新WPS平台的webhook配置
3. 建议在测试环境先验证后再更新生产环境
4. 如有问题，查看详细文档或使用 `./status.sh --logs` 查看日志

---

**更新人**: AI Assistant  
**版本**: v4.0  
**完成时间**: 2026-01-30
