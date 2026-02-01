#!/bin/bash
# Docker部署测试脚本

set -e

echo "=========================================="
echo "WPS机器人系统 Docker部署测试"
echo "=========================================="

# 检查Docker
echo "1. 检查Docker环境..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装"
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装"
    exit 1
fi
echo "✓ Docker环境检查通过"

# 检查必要文件
echo ""
echo "2. 检查项目文件..."
required_files=("Dockerfile" "docker-compose.yml" "manage.py" "requirements.txt")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺少文件: $file"
        exit 1
    fi
done
echo "✓ 项目文件完整"

# 停止现有容器
echo ""
echo "3. 停止现有容器..."
docker-compose down 2>/dev/null || true
echo "✓ 现有容器已停止"

# 构建镜像
echo ""
echo "4. 构建Docker镜像..."
docker-compose build
if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi
echo "✓ 镜像构建成功"

# 启动容器
echo ""
echo "5. 启动容器..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "❌ 容器启动失败"
    exit 1
fi
echo "✓ 容器启动成功"

# 等待服务就绪
echo ""
echo "6. 等待服务就绪..."
sleep 10

# 检查容器状态
echo ""
echo "7. 检查容器状态..."
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ 容器未正常运行"
    docker-compose logs web
    exit 1
fi
echo "✓ 容器正常运行"

# 测试HTTP访问
echo ""
echo "8. 测试HTTP访问..."
if command -v curl &> /dev/null; then
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login/ || echo "000")
    if [ "$response" = "200" ]; then
        echo "✓ HTTP访问正常 (状态码: $response)"
    else
        echo "⚠️  HTTP访问异常 (状态码: $response)"
        echo "   这可能是正常的，请手动检查"
    fi
else
    echo "⚠️  curl未安装，跳过HTTP测试"
fi

# 显示日志
echo ""
echo "9. 显示最近日志..."
docker-compose logs --tail=20 web

# 显示访问信息
echo ""
echo "=========================================="
echo "✅ 部署测试完成！"
echo "=========================================="
echo ""
echo "访问信息:"
echo "  URL: http://localhost:8080"
echo "  用户名: admin"
echo "  密码: admin123456"
echo ""
echo "常用命令:"
echo "  查看日志: docker-compose logs -f web"
echo "  停止服务: docker-compose stop"
echo "  重启服务: docker-compose restart"
echo "  进入容器: docker-compose exec web bash"
echo "  完全停止: docker-compose down"
echo ""
echo "=========================================="
