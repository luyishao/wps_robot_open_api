#!/bin/bash
# Docker镜像构建问题快速修复脚本

set -e

echo "=========================================="
echo "Docker镜像构建问题修复工具"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. 检查Docker是否运行
echo "1. 检查Docker服务..."
if ! sudo systemctl is-active --quiet docker; then
    echo -e "${YELLOW}Docker服务未运行，正在启动...${NC}"
    sudo systemctl start docker
    sleep 2
fi
echo -e "${GREEN}✓ Docker服务正常${NC}"
echo ""

# 2. 清理Docker缓存
echo "2. 清理Docker缓存和未使用资源..."
echo "   - 清理构建缓存..."
docker builder prune -a -f > /dev/null 2>&1
echo "   - 清理未使用的镜像..."
docker image prune -a -f > /dev/null 2>&1
echo "   - 清理未使用的容器..."
docker container prune -f > /dev/null 2>&1
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

# 3. 配置镜像加速（可选）
echo "3. 配置Docker镜像加速..."
read -p "   是否配置中国大陆镜像加速？这将提高镜像下载速度 (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "   正在配置镜像加速..."
    sudo tee /etc/docker/daemon.json > /dev/null <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com",
    "https://docker.m.daocloud.io"
  ]
}
EOF
    echo "   重启Docker服务..."
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sleep 3
    echo -e "${GREEN}✓ 镜像加速已配置${NC}"
else
    echo -e "${YELLOW}⊘ 跳过镜像加速配置${NC}"
fi
echo ""

# 4. 删除可能损坏的Python镜像
echo "4. 删除可能损坏的Python镜像..."
if docker images | grep -q "python.*3.12"; then
    docker rmi python:3.12 -f > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ 已删除旧的Python镜像${NC}"
else
    echo -e "${YELLOW}⊘ 未找到需要删除的镜像${NC}"
fi
echo ""

# 5. 手动拉取基础镜像
echo "5. 手动拉取Python基础镜像..."
echo "   尝试拉取 python:3.12（标准版）..."
if docker pull python:3.12; then
    echo -e "${GREEN}✓ 成功拉取 python:3.12${NC}"
    BASE_IMAGE="python:3.12"
else
    echo -e "${YELLOW}⚠ python:3.12 拉取失败，尝试 python:3.11...${NC}"
    if docker pull python:3.11; then
        echo -e "${GREEN}✓ 成功拉取 python:3.11${NC}"
        BASE_IMAGE="python:3.11"
        
        # 修改Dockerfile
        echo "   正在修改Dockerfile使用python:3.11..."
        if [ -f "Dockerfile" ]; then
            sed -i.bak 's/FROM python:3.12/FROM python:3.11/' Dockerfile
            echo -e "${GREEN}✓ Dockerfile已更新${NC}"
        fi
    else
        echo -e "${RED}✗ 无法拉取Python镜像，请检查网络连接${NC}"
        exit 1
    fi
fi
echo ""

# 6. 检查磁盘空间
echo "6. 检查磁盘空间..."
AVAILABLE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
if command -v bc >/dev/null 2>&1; then
    if (( $(echo "$AVAILABLE < 5" | bc -l 2>/dev/null || echo 0) )); then
        echo -e "${RED}✗ 警告：可用磁盘空间不足5GB，可能导致构建失败${NC}"
        echo "   当前可用空间: ${AVAILABLE}GB"
        read -p "   是否继续？(y/n): " continue_choice
        if [ "$continue_choice" != "y" ] && [ "$continue_choice" != "Y" ]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✓ 磁盘空间充足 (${AVAILABLE}GB可用)${NC}"
    fi
else
    echo -e "${GREEN}✓ 磁盘空间检查完成${NC}"
fi
echo ""

# 7. 重新构建项目
echo "7. 重新构建项目镜像..."
echo "   这可能需要几分钟时间，请耐心等待..."
echo ""

if docker compose build --no-cache; then
    echo ""
    echo -e "${GREEN}✓ 镜像构建成功！${NC}"
else
    echo ""
    echo -e "${RED}✗ 镜像构建失败${NC}"
    echo ""
    echo "可能的原因："
    echo "  1. 网络问题 - 尝试配置镜像加速或使用VPN"
    echo "  2. 磁盘空间不足 - 清理磁盘空间"
    echo "  3. Docker服务异常 - 重启Docker服务"
    echo ""
    echo "详细排查指南："
    echo "  查看文档: FIX_DOCKER_BUILD_ERROR.md"
    exit 1
fi
echo ""

# 8. 启动容器
echo "8. 启动容器..."
if docker compose up -d; then
    echo -e "${GREEN}✓ 容器启动成功${NC}"
else
    echo -e "${RED}✗ 容器启动失败${NC}"
    exit 1
fi
echo ""

# 9. 等待服务就绪
echo "9. 等待服务就绪..."
sleep 10

# 10. 检查容器状态
echo "10. 检查容器状态..."
if docker compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ 容器运行正常${NC}"
else
    echo -e "${RED}✗ 容器未正常运行${NC}"
    echo "查看日志: docker compose logs web"
    exit 1
fi
echo ""

# 完成
echo "=========================================="
echo -e "${GREEN}✅ 修复完成！${NC}"
echo "=========================================="
echo ""
echo "访问信息:"
echo "  URL: http://localhost:8080"
echo "  或: http://$(hostname -I | awk '{print $1}'):8080"
echo "  用户名: admin"
echo "  密码: admin123456"
echo ""
echo "常用命令:"
echo "  查看状态: docker compose ps"
echo "  查看日志: docker compose logs -f web"
echo "  停止服务: docker compose stop"
echo "  重启服务: docker compose restart"
echo "  进入容器: docker compose exec web bash"
echo ""
echo "=========================================="
