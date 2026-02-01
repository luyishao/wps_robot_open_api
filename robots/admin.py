from django.contrib import admin
from .models import Robot, Message, UserProfile


@admin.register(Robot)
class RobotAdmin(admin.ModelAdmin):
    list_display = ['name', 'owner', 'is_active', 'created_at']
    list_filter = ['is_active', 'created_at']
    search_fields = ['name', 'owner__username']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['robot', 'direction', 'status', 'created_at']
    list_filter = ['direction', 'status', 'created_at']
    search_fields = ['robot__name']
    readonly_fields = ['created_at', 'formatted_log_data']
    
    def formatted_log_data(self, obj):
        """格式化显示log数据"""
        if obj.log_data:
            import json
            return json.dumps(obj.log_data, indent=2, ensure_ascii=False)
        return "无日志数据"
    formatted_log_data.short_description = 'Log数据'


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'is_admin', 'created_at']
    list_filter = ['is_admin', 'created_at']
    search_fields = ['user__username']
