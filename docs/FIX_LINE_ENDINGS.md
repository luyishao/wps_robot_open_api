# 🔧 Linux脚本换行符错误修复指南

## ❌ 错误信息

```bash
./fix-docker-build.sh: line 3: $'\r': command not found
```

## 🐛 问题原因

这是**Windows/Linux换行符不兼容**问题：
- **Windows**: 使用 CRLF（`\r\n`）作为换行符
- **Linux**: 使用 LF（`\n`）作为换行符
- **macOS**: 也使用 LF（`\n`）

当在Windows系统创建或编辑文件后上传到Linux，会导致这个问题。

## ✅ 解决方案

### 方案1：使用 dos2unix 工具（推荐）⭐

#### 1.1 安装 dos2unix

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install dos2unix
```

**CentOS/RHEL**:
```bash
sudo yum install dos2unix
```

**Fedora**:
```bash
sudo dnf install dos2unix
```

#### 1.2 转换文件

```bash
# 转换单个文件
dos2unix fix-docker-build.sh

# 转换多个文件
dos2unix *.sh

# 转换所有Shell脚本
find . -name "*.sh" -exec dos2unix {} \;
```

#### 1.3 添加执行权限并运行

```bash
chmod +x fix-docker-build.sh
./fix-docker-build.sh
```

---

### 方案2：使用 sed 命令

```bash
# 移除 \r 字符
sed -i 's/\r$//' fix-docker-build.sh

# 批量转换所有 .sh 文件
for file in *.sh; do
    sed -i 's/\r$//' "$file"
    chmod +x "$file"
done

# 运行脚本
./fix-docker-build.sh
```

---

### 方案3：使用自动修复脚本⭐

我们已经创建了自动修复工具：

```bash
# 1. 首先修复修复工具本身
sed -i 's/\r$//' fix-line-endings.sh
chmod +x fix-line-endings.sh

# 2. 运行修复工具
./fix-line-endings.sh

# 3. 现在可以运行原脚本了
./fix-docker-build.sh
```

---

### 方案4：使用 vim 编辑器

```bash
# 打开文件
vim fix-docker-build.sh

# 在 vim 中执行以下命令
:set ff=unix
:wq

# 添加执行权限
chmod +x fix-docker-build.sh

# 运行脚本
./fix-docker-build.sh
```

---

### 方案5：使用 tr 命令

```bash
# 删除 \r 字符
tr -d '\r' < fix-docker-build.sh > fix-docker-build-unix.sh

# 替换原文件
mv fix-docker-build-unix.sh fix-docker-build.sh

# 添加执行权限
chmod +x fix-docker-build.sh

# 运行脚本
./fix-docker-build.sh
```

---

## 🚀 一键修复（推荐）

### 完整解决命令

```bash
# 方案A：使用 dos2unix（如果已安装）
dos2unix fix-docker-build.sh && chmod +x fix-docker-build.sh && ./fix-docker-build.sh

# 方案B：使用 sed
sed -i 's/\r$//' fix-docker-build.sh && chmod +x fix-docker-build.sh && ./fix-docker-build.sh
```

---

## 📝 批量修复所有脚本

### 创建批量修复脚本

```bash
# 创建修复脚本
cat > fix-all-scripts.sh << 'EOF'
#!/bin/bash
echo "修复所有Shell脚本的换行符..."

count=0
for file in *.sh; do
    if [ -f "$file" ]; then
        sed -i 's/\r$//' "$file"
        chmod +x "$file"
        echo "✓ 已修复: $file"
        ((count++))
    fi
done

echo ""
echo "完成！共修复 $count 个文件"
EOF

# 运行修复
bash fix-all-scripts.sh
```

---

## 🔍 检查文件换行符类型

### 查看文件换行符

```bash
# 使用 file 命令
file fix-docker-build.sh
# CRLF: with CRLF line terminators
# LF: with LF line terminators

# 使用 od 命令查看十六进制
od -c fix-docker-build.sh | head

# 使用 cat 显示特殊字符
cat -A fix-docker-build.sh | head
# ^M$ 表示 CRLF (Windows)
# $ 表示 LF (Unix)
```

---

## 🛡️ 预防措施

### 1. 配置 Git 自动转换

在项目根目录创建 `.gitattributes` 文件：

```bash
cat > .gitattributes << 'EOF'
# 自动转换文本文件的换行符
* text=auto

# Shell脚本始终使用 LF
*.sh text eol=lf

# Python文件使用 LF
*.py text eol=lf

# Windows批处理文件使用 CRLF
*.bat text eol=crlf
*.cmd text eol=crlf
EOF
```

### 2. 配置编辑器

**VS Code** (settings.json):
```json
{
  "files.eol": "\n",
  "files.insertFinalNewline": true
}
```

**Vim** (.vimrc):
```vim
set fileformat=unix
```

**Notepad++**:
- 编辑 → EOL转换 → Unix (LF)

### 3. 在Windows上正确创建脚本

如果在Windows上创建Shell脚本：

**使用Git Bash**:
```bash
# 在 Git Bash 中创建文件会自动使用 LF
nano script.sh
```

**使用 WSL**:
```bash
# Windows Subsystem for Linux 中创建的文件使用 LF
```

---

## 📚 常见问题

### Q1: 为什么会出现这个问题？

**A**: 当您在Windows系统中：
- 使用记事本或某些编辑器创建文件
- 从Windows复制文件到Linux
- 通过FTP在文本模式传输文件

都可能导致换行符变成CRLF。

---

### Q2: 如何避免这个问题？

**A**: 
1. 在Linux服务器上直接创建和编辑脚本
2. 使用支持Linux换行符的编辑器（VS Code、Notepad++）
3. 配置Git自动转换（.gitattributes）
4. 使用二进制模式上传文件

---

### Q3: 转换后文件有什么变化？

**A**: 
- 每行末尾的 `\r` 字符被移除
- 文件大小会略微减小
- 功能完全不变

---

### Q4: 其他文件类型也有这个问题吗？

**A**: 
是的，以下文件类型都可能受影响：
- Shell脚本 (`.sh`)
- Python脚本 (`.py`)
- 配置文件 (`.conf`, `.cfg`)
- 数据文件
- 任何文本文件

---

## 🎯 完整解决流程

```bash
# 1. 进入项目目录
cd /path/to/wps_open_api

# 2. 检查是否有换行符问题
file fix-docker-build.sh

# 3. 修复换行符（选择一种方法）
# 方法A: 使用 dos2unix
sudo apt-get install dos2unix  # 如果未安装
dos2unix fix-docker-build.sh

# 方法B: 使用 sed
sed -i 's/\r$//' fix-docker-build.sh

# 4. 添加执行权限
chmod +x fix-docker-build.sh

# 5. 运行脚本
./fix-docker-build.sh
```

---

## 💡 快速参考

### 检测换行符
```bash
file filename.sh
```

### 转换为Unix格式
```bash
dos2unix filename.sh          # 推荐
sed -i 's/\r$//' filename.sh  # 备选
```

### 批量转换
```bash
dos2unix *.sh
# 或
find . -name "*.sh" -exec sed -i 's/\r$//' {} \;
```

### 添加执行权限
```bash
chmod +x filename.sh
```

---

## 🔗 相关资源

- [dos2unix 官方文档](https://waterlan.home.xs4all.nl/dos2unix.html)
- [Git 换行符处理](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings)
- [EditorConfig](https://editorconfig.org/)

---

**更新时间**: 2026-01-30  
**问题类型**: 换行符不兼容  
**适用系统**: Linux/Unix/macOS
