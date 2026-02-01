# 文件重命名记录

## 更新时间
2026-01-30

## 变更说明

### 主要变更
将 `deploy.sh` 重命名为 `start.sh`，使脚本名称更加直观和易用。

### 文件变更

#### 新增文件
- ✅ `start.sh` - 一键启动脚本（原deploy.sh）

#### 删除文件
- ❌ `deploy.sh` - 已重命名为start.sh

#### 更新的文档文件
1. `SHELL_SCRIPTS_README.md` - 更新所有deploy.sh引用为start.sh
2. `docs/SHELL_DEPLOY_SUMMARY.md` - 更新所有deploy.sh引用为start.sh
3. `README.md` - 更新Shell脚本部署说明
4. `QUICK_REFERENCE.md` - 更新快速参考命令

### 使用说明

原命令：
```bash
chmod +x deploy.sh
./deploy.sh
./deploy.sh --mode=docker
./deploy.sh --port=9000
./deploy.sh --clean
```

新命令：
```bash
chmod +x start.sh
./start.sh
./start.sh --mode=docker
./start.sh --port=9000
./start.sh --clean
```

### 功能不变
- 所有功能保持不变
- 所有选项参数保持不变
- 脚本版本：1.0.0

### 兼容性说明
- 旧的 `deploy.sh` 文件已删除
- 所有文档已更新为新的脚本名称
- 如有其他自定义脚本引用了 `deploy.sh`，请手动更新为 `start.sh`

---
更新人：AI Assistant
