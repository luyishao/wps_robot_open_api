from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


class Robot(models.Model):
    """机器人模型"""
    name = models.CharField('机器人名称', max_length=100)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='robots', verbose_name='所有者')
    webhook_url = models.URLField('Webhook URL', max_length=500, blank=True, help_text='发送消息到WPS的webhook地址')
    description = models.TextField('描述', blank=True)
    hook_script = models.CharField('Hook脚本', max_length=200, blank=True, help_text='处理消息的Python脚本文件名（不含.py）')
    hook_script_file = models.FileField('Hook脚本文件', upload_to='hook_scripts/', blank=True, null=True, help_text='上传Python脚本文件')
    max_message_count = models.IntegerField('最大消息记录数', default=100, help_text='保留的最大消息数量（1-1000）')
    is_active = models.BooleanField('是否启用', default=True)
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        verbose_name = '机器人'
        verbose_name_plural = '机器人'
        unique_together = [['owner', 'name']]
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.owner.username}/{self.name}"
    
    def get_webhook_callback_url(self, request=None):
        """获取webhook回调地址（相对路径）"""
        return f"/at_robot/{self.owner.username}/{self.name}"
    
    def clean_old_messages(self):
        """清理超过限制的旧消息"""
        messages = self.messages.order_by('-created_at')
        total_count = messages.count()
        if total_count > self.max_message_count:
            # 删除超出限制的旧消息
            messages_to_delete = messages[self.max_message_count:]
            Message.objects.filter(id__in=[m.id for m in messages_to_delete]).delete()


class Message(models.Model):
    """消息记录模型"""
    DIRECTION_CHOICES = [
        ('incoming', '接收'),
        ('outgoing', '发送'),
    ]
    
    STATUS_CHOICES = [
        ('success', '成功'),
        ('failed', '失败'),
        ('pending', '处理中'),
    ]
    
    robot = models.ForeignKey(Robot, on_delete=models.CASCADE, related_name='messages', verbose_name='机器人')
    direction = models.CharField('方向', max_length=10, choices=DIRECTION_CHOICES)
    content = models.JSONField('内容', help_text='消息的JSON数据')
    status = models.CharField('状态', max_length=10, choices=STATUS_CHOICES, default='success')
    error_message = models.TextField('错误信息', blank=True)
    response_data = models.JSONField('响应数据', null=True, blank=True)
    log_data = models.JSONField('日志数据', null=True, blank=True, help_text='记录请求和响应的详细参数')
    created_at = models.DateTimeField('创建时间', default=timezone.now)
    
    class Meta:
        verbose_name = '消息'
        verbose_name_plural = '消息'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.robot} - {self.get_direction_display()} - {self.created_at}"
    
    def formatted_log(self):
        """返回格式化的log数据"""
        if self.log_data:
            import json
            try:
                return json.dumps(self.log_data, indent=2, ensure_ascii=False, sort_keys=True)
            except:
                return str(self.log_data)
        return ''


class UserProfile(models.Model):
    """用户扩展信息"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile', verbose_name='用户')
    is_admin = models.BooleanField('是否为管理员', default=False)
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    
    class Meta:
        verbose_name = '用户配置'
        verbose_name_plural = '用户配置'
    
    def __str__(self):
        return self.user.username
