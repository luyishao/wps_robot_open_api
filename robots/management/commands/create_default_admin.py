from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from django.conf import settings
from robots.models import UserProfile


class Command(BaseCommand):
    help = '创建默认管理员账号'

    def handle(self, *args, **options):
        username = settings.DEFAULT_ADMIN_USERNAME
        password = settings.DEFAULT_ADMIN_PASSWORD
        
        # 检查用户是否已存在
        if User.objects.filter(username=username).exists():
            self.stdout.write(
                self.style.WARNING(f'用户 "{username}" 已存在')
            )
            return
        
        # 创建用户
        user = User.objects.create_user(
            username=username,
            password=password,
            is_staff=True,
            is_superuser=True
        )
        
        # 创建用户配置
        UserProfile.objects.create(
            user=user,
            is_admin=True
        )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'成功创建管理员账号:\n'
                f'用户名: {username}\n'
                f'密码: {password}\n'
                f'请在生产环境中修改密码！'
            )
        )
