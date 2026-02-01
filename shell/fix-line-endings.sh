#!/bin/bash
# 修复Windows换行符问题的工具

echo "====================================="
echo "换行符修复工具"
echo "====================================="
echo ""

# 检查是否安装了 dos2unix
if command -v dos2unix >/dev/null 2>&1; then
    echo "使用 dos2unix 修复..."
    METHOD="dos2unix"
else
    echo "使用 sed 修复..."
    METHOD="sed"
fi

echo ""

# 修复所有 .sh 文件
count=0
for file in *.sh; do
    if [ -f "$file" ]; then
        if [ "$METHOD" = "dos2unix" ]; then
            dos2unix "$file" 2>/dev/null
        else
            sed -i 's/\r$//' "$file"
        fi
        chmod +x "$file"
        echo "✓ 已修复: $file"
        ((count++))
    fi
done

echo ""
echo "====================================="
echo "修复完成！共修复 $count 个文件"
echo "====================================="
echo ""
echo "现在可以运行脚本了："
echo "  ./fix-docker-build.sh"
echo ""
