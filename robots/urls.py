from django.urls import path
from . import views

urlpatterns = [
    # 认证
    path('login/', views.user_login, name='login'),
    path('logout/', views.user_logout, name='logout'),
    
    # 控制台
    path('', views.dashboard, name='dashboard'),
    
    # 机器人管理
    path('robots/', views.robot_list, name='robot_list'),
    path('robots/create/', views.robot_create, name='robot_create'),
    path('robots/<int:robot_id>/', views.robot_detail, name='robot_detail'),
    path('robots/<int:robot_id>/edit/', views.robot_edit, name='robot_edit'),
    path('robots/<int:robot_id>/delete/', views.robot_delete, name='robot_delete'),
    path('robots/<int:robot_id>/send/', views.send_message, name='send_message'),
    
    # 消息管理
    path('messages/', views.message_list, name='message_list'),
    
    # 用户管理（管理员）
    path('users/', views.user_management, name='user_management'),
    path('users/create/', views.user_create, name='user_create'),
    path('users/<int:user_id>/edit/', views.user_edit, name='user_edit'),
    path('users/<int:user_id>/delete/', views.user_delete, name='user_delete'),
    
    # 日志管理
    path('logs/', views.logs_viewer, name='logs_viewer'),
    path('logs/download/<str:log_name>', views.download_log, name='download_log'),
    path('logs/download-all/', views.download_all_logs, name='download_all_logs'),
    path('logs/clear/', views.clear_logs, name='clear_logs'),
    path('api/logs/tail/', views.api_log_tail, name='api_log_tail'),
    
    # Webhook回调（无需登录验证）
    path('at_robot/<str:username>/<str:robot_name>', views.webhook_callback, name='webhook_callback'),
]
