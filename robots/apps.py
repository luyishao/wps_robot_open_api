import logging
from django.apps import AppConfig


class RobotsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'robots'
    verbose_name = '机器人管理'

    def ready(self):
        # 应用加载时写一条日志，确保 django.log 等文件被创建，Web 日志查看器能正常显示
        logger = logging.getLogger('django')
        logger.info('robots app ready (logging to file for web logs viewer)')
