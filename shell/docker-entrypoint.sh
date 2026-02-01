#!/bin/sh
# Docker容器初始化脚本

set -e

echo "=========================================="
echo "WPS机器人系统 - 容器初始化"
echo "=========================================="

# 等待数据库准备就绪（如果使用外部数据库）
# echo "等待数据库..."
# python manage.py wait_for_db

# 执行数据库迁移
echo "执行数据库迁移..."
python manage.py migrate --noinput

# 创建超级用户（如果不存在）
echo "检查超级用户..."
python manage.py shell << EOF
from django.contrib.auth.models import User
from robots.models import UserProfile

if not User.objects.filter(username='admin').exists():
    user = User.objects.create_superuser('admin', 'admin@example.com', 'admin123456')
    UserProfile.objects.create(user=user, is_admin=True)
    print("✓ 创建超级用户: admin/admin123456")
else:
    print("✓ 超级用户已存在")
EOF

# 收集静态文件
echo "收集静态文件..."
python manage.py collectstatic --noinput --clear || true

# 设置目录权限
echo "设置目录权限..."
chmod -R 755 media/ || true
chmod -R 755 staticfiles/ || true

echo "=========================================="
echo "初始化完成！启动应用..."
echo "=========================================="

# 启动应用
exec "$@"
