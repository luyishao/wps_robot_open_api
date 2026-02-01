import json
import importlib
import logging
import traceback
import os
import zipfile
import io
from pathlib import Path
from datetime import datetime, timedelta
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib import messages
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.db.models import Q
from django.core.paginator import Paginator
from django.conf import settings
import requests

from .models import Robot, Message, UserProfile
from .forms import RobotForm, SendMessageForm, UserCreateForm, UserEditForm

logger = logging.getLogger('robots')


def user_login(request):
    """用户登录"""
    if request.user.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            return redirect('dashboard')
        else:
            messages.error(request, '用户名或密码错误')
    
    return render(request, 'robots/login.html')


@login_required
def user_logout(request):
    """用户登出"""
    logout(request)
    messages.success(request, '您已成功登出')
    return redirect('login')


@login_required
def dashboard(request):
    """控制台首页"""
    robots = Robot.objects.filter(owner=request.user)
    recent_messages = Message.objects.filter(robot__owner=request.user)[:10]
    
    context = {
        'robots': robots,
        'recent_messages': recent_messages,
    }
    return render(request, 'robots/dashboard.html', context)


@login_required
def robot_list(request):
    """机器人列表"""
    robots = Robot.objects.filter(owner=request.user)
    return render(request, 'robots/robot_list.html', {'robots': robots})


@login_required
def robot_create(request):
    """创建机器人"""
    if request.method == 'POST':
        form = RobotForm(request.POST, request.FILES)
        if form.is_valid():
            robot = form.save(commit=False)
            robot.owner = request.user
            robot.save()
            messages.success(request, f'机器人 "{robot.name}" 创建成功')
            return redirect('robot_detail', robot_id=robot.id)
    else:
        form = RobotForm()
    
    return render(request, 'robots/robot_form.html', {'form': form, 'action': '创建'})


@login_required
def robot_edit(request, robot_id):
    """编辑机器人"""
    robot = get_object_or_404(Robot, id=robot_id, owner=request.user)
    
    if request.method == 'POST':
        form = RobotForm(request.POST, request.FILES, instance=robot)
        if form.is_valid():
            form.save()
            messages.success(request, f'机器人 "{robot.name}" 更新成功')
            return redirect('robot_detail', robot_id=robot.id)
    else:
        form = RobotForm(instance=robot)
    
    return render(request, 'robots/robot_form.html', {
        'form': form,
        'robot': robot,
        'action': '编辑'
    })


@login_required
def robot_delete(request, robot_id):
    """删除机器人"""
    robot = get_object_or_404(Robot, id=robot_id, owner=request.user)
    
    if request.method == 'POST':
        robot_name = robot.name
        robot.delete()
        messages.success(request, f'机器人 "{robot_name}" 已删除')
        return redirect('robot_list')
    
    return render(request, 'robots/robot_confirm_delete.html', {'robot': robot})


@login_required
def robot_detail(request, robot_id):
    """机器人详情"""
    robot = get_object_or_404(Robot, id=robot_id, owner=request.user)
    messages_list = Message.objects.filter(robot=robot)
    
    # 分页
    paginator = Paginator(messages_list, 20)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    # 获取webhook回调地址
    webhook_callback_url = robot.get_webhook_callback_url(request)
    
    context = {
        'robot': robot,
        'page_obj': page_obj,
        'webhook_callback_url': webhook_callback_url,
    }
    return render(request, 'robots/robot_detail.html', context)


@login_required
def send_message(request, robot_id):
    """发送消息到机器人webhook"""
    robot = get_object_or_404(Robot, id=robot_id, owner=request.user)
    
    if not robot.webhook_url:
        messages.error(request, '机器人未配置 Webhook URL')
        return redirect('robot_detail', robot_id=robot.id)
    
    if request.method == 'POST':
        form = SendMessageForm(request.POST)
        if form.is_valid():
            msg_type = form.cleaned_data['msg_type']
            content = form.cleaned_data.get('content', '')
            card_title = form.cleaned_data.get('card_title', '')
            card_text = form.cleaned_data.get('card_text', '')
            
            # 构造消息数据
            if msg_type == 'text':
                message_data = {
                    'msgtype': 'text',
                    'text': {
                        'content': content
                    }
                }
            elif msg_type == 'markdown':
                message_data = {
                    'msgtype': 'markdown',
                    'markdown': {
                        'text': content
                    }
                }
            else:  # card
                # 如果提供了JSON格式的content，尝试解析
                if content.strip().startswith('{'):
                    try:
                        card_data = json.loads(content)
                        
                        # 卡片消息：直接使用输入的JSON作为card内容
                        # 无论输入什么格式，都作为card的内容
                        message_data = {
                            'msgtype': 'card',
                            'card': card_data
                        }
                    except json.JSONDecodeError as e:
                        messages.error(request, f'卡片JSON格式错误: {str(e)}')
                        return render(request, 'robots/send_message.html', {
                            'form': form,
                            'robot': robot
                        })
                else:
                    # 使用简单的标题和文本构造卡片
                    message_data = {
                        'msgtype': 'card',
                        'card': {
                            'header': {
                                'title': {
                                    'tag': 'text',
                                    'content': {
                                        'type': 'plainText',
                                        'text': card_title or '卡片消息'
                                    }
                                }
                            },
                            'elements': [
                                {
                                    'tag': 'text',
                                    'content': {
                                        'type': 'plainText',
                                        'text': card_text or content
                                    }
                                }
                            ]
                        }
                    }
            
            # 发送消息
            message_record = Message.objects.create(
                robot=robot,
                direction='outgoing',
                content=message_data,
                status='pending',
                log_data={
                    'request': {
                        'url': robot.webhook_url,
                        'method': 'POST',
                        'headers': {'Content-Type': 'application/json'},
                        'body': message_data
                    }
                }
            )
            
            try:
                response = requests.post(
                    robot.webhook_url,
                    json=message_data,
                    timeout=10
                )
                
                # 记录响应信息到log
                log_data = message_record.log_data or {}
                log_data['response'] = {
                    'status_code': response.status_code,
                    'headers': dict(response.headers),
                    'body': response.json() if response.content else {},
                    'text': response.text[:500] if len(response.text) > 500 else response.text
                }
                message_record.log_data = log_data
                
                if response.status_code == 200:
                    message_record.status = 'success'
                    message_record.response_data = response.json() if response.content else {}
                    messages.success(request, '消息发送成功')
                else:
                    message_record.status = 'failed'
                    message_record.error_message = f'HTTP {response.status_code}: {response.text}'
                    messages.error(request, f'消息发送失败: HTTP {response.status_code}')
            
            except Exception as e:
                message_record.status = 'failed'
                message_record.error_message = str(e)
                
                # 记录异常信息到log
                log_data = message_record.log_data or {}
                log_data['error'] = {
                    'type': type(e).__name__,
                    'message': str(e),
                    'traceback': traceback.format_exc()
                }
                message_record.log_data = log_data
                
                messages.error(request, f'消息发送失败: {str(e)}')
            
            message_record.save()
            
            # 清理旧消息
            robot.clean_old_messages()
            
            return redirect('robot_detail', robot_id=robot.id)
    else:
        form = SendMessageForm()
    
    return render(request, 'robots/send_message.html', {
        'form': form,
        'robot': robot
    })


@csrf_exempt
@require_http_methods(["GET", "POST"])
def webhook_callback(request, username, robot_name):
    """接收webhook回调"""
    raw_body = request.body
    request_raw = (raw_body[:2000].decode('utf-8', errors='replace') + (' ... (truncated)' if len(raw_body) > 2000 else '')) if raw_body else '(empty)'

    # 请求参数和 body 输出到控制台和日志文件（含 request_raw 列）
    logger.info(
        'webhook 请求: method=%s path=%s username=%s robot_name=%s query=%s | request_raw=%s',
        request.method, request.path, username, robot_name, dict(request.GET), request_raw
    )

    try:
        # 获取用户和机器人
        try:
            user = User.objects.get(username=username)
            robot = Robot.objects.get(owner=user, name=robot_name, is_active=True)
        except (User.DoesNotExist, Robot.DoesNotExist):
            resp_body = {'error': 'Robot not found'}
            response_raw = json.dumps(resp_body, ensure_ascii=False)
            logger.error(
                'webhook 响应错误 404: request_raw=%s | response_raw=%s | 响应 body=%s',
                request_raw, response_raw, resp_body
            )
            return JsonResponse(resp_body, status=404)
        
        # GET请求：WPS验证回调地址
        if request.method == 'GET':
            get_resp = {'result': 'ok'}
            logger.info(
                'webhook 响应 GET 200: request_raw=%s | response_raw=%s',
                request_raw, json.dumps(get_resp, ensure_ascii=False)
            )
            return JsonResponse(get_resp)
        
        # POST请求:处理消息
        # 解析请求数据（空 body 或 Go/部分客户端发来的请求按 {} 处理，避免 400）
        if not raw_body or not raw_body.strip():
            data = {}
        else:
            try:
                data = json.loads(raw_body.decode('utf-8'))
            except (json.JSONDecodeError, UnicodeDecodeError):
                resp_body = {
                    'error': 'Invalid JSON',
                    'hint': 'Send Content-Type: application/json and valid JSON body (e.g. {} for empty)'
                }
                logger.error(
                    'webhook 响应错误 400: 请求 body(raw)=%s | 响应 body=%s',
                    raw_body[:2000].decode('utf-8', errors='replace') if raw_body else '(empty)',
                    resp_body
                )
                return JsonResponse(resp_body, status=400)
        logger.info('webhook 请求 body (parsed): %s', data)
        
        # 构建log数据
        log_data = {
            'request': {
                'method': request.method,
                'path': request.path,
                'headers': dict(request.headers),
                'body': data,
                'remote_addr': request.META.get('REMOTE_ADDR'),
                'user_agent': request.META.get('HTTP_USER_AGENT')
            }
        }
        
        # 保存接收到的消息
        message_record = Message.objects.create(
            robot=robot,
            direction='incoming',
            content=data,
            status='success',
            log_data=log_data
        )
        
        # 清理旧消息
        robot.clean_old_messages()
        
        # 处理hook脚本
        response_data = None
        hook_execution_log = {}
        
        # 优先使用上传的脚本文件
        if robot.hook_script_file:
            try:
                import sys
                import tempfile
                import shutil
                
                hook_execution_log['hook_type'] = 'uploaded_file'
                hook_execution_log['file_name'] = robot.hook_script_file.name
                
                # 创建临时目录并保存脚本
                with tempfile.TemporaryDirectory() as temp_dir:
                    script_path = os.path.join(temp_dir, 'uploaded_hook.py')
                    with open(script_path, 'wb') as f:
                        robot.hook_script_file.seek(0)
                        f.write(robot.hook_script_file.read())
                    
                    # 添加临时目录到sys.path
                    sys.path.insert(0, temp_dir)
                    
                    try:
                        # 动态导入上传的脚本
                        import uploaded_hook
                        importlib.reload(uploaded_hook)
                        
                        if hasattr(uploaded_hook, 'process_message'):
                            response_data = uploaded_hook.process_message(robot, data)
                            message_record.response_data = response_data
                            hook_execution_log['status'] = 'success'
                            hook_execution_log['response'] = response_data
                    finally:
                        # 清理sys.path
                        sys.path.remove(temp_dir)
                        # 删除模块
                        if 'uploaded_hook' in sys.modules:
                            del sys.modules['uploaded_hook']
                            
            except Exception as e:
                message_record.status = 'failed'
                message_record.error_message = f'Uploaded hook script error: {str(e)}\n{traceback.format_exc()}'
                hook_execution_log['status'] = 'error'
                hook_execution_log['error'] = {
                    'type': type(e).__name__,
                    'message': str(e),
                    'traceback': traceback.format_exc()
                }
        
        # 如果没有上传文件，使用预设的hook脚本
        elif robot.hook_script:
            try:
                hook_execution_log['hook_type'] = 'preset'
                hook_execution_log['script_name'] = robot.hook_script
                
                # 动态导入hook脚本
                hook_module = importlib.import_module(f'robots.hooks.{robot.hook_script}')
                if hasattr(hook_module, 'process_message'):
                    response_data = hook_module.process_message(robot, data)
                    message_record.response_data = response_data
                    hook_execution_log['status'] = 'success'
                    hook_execution_log['response'] = response_data
            except Exception as e:
                message_record.status = 'failed'
                message_record.error_message = f'Hook script error: {str(e)}\n{traceback.format_exc()}'
                hook_execution_log['status'] = 'error'
                hook_execution_log['error'] = {
                    'type': type(e).__name__,
                    'message': str(e),
                    'traceback': traceback.format_exc()
                }
        
        # 更新log数据，添加hook执行信息
        if hook_execution_log:
            log_data = message_record.log_data or {}
            log_data['hook_execution'] = hook_execution_log
            message_record.log_data = log_data
        
        # 准备响应数据
        if response_data:
            final_response = response_data
        else:
            final_response = {'result': 'ok'}
        
        # 记录响应信息到log
        log_data = message_record.log_data or {}
        log_data['response'] = {
            'status_code': 200,
            'body': final_response
        }
        message_record.log_data = log_data
        
        message_record.save()
        
        # 成功响应：记录 request_raw、response_raw 及解析后的 body
        response_raw = json.dumps(final_response, ensure_ascii=False)
        logger.info(
            'webhook 响应成功 200: request_raw=%s | response_raw=%s | 请求 body(parsed)=%s | 响应 body=%s',
            request_raw, response_raw, data, final_response
        )
        return JsonResponse(final_response)
    
    except Exception as e:
        resp_body = {'error': 'Internal server error', 'message': str(e)}
        response_raw = json.dumps(resp_body, ensure_ascii=False)
        logger.error(
            'webhook 响应错误 500: request_raw=%s | response_raw=%s | 异常=%s traceback=%s | 响应 body=%s',
            request_raw, response_raw, type(e).__name__, traceback.format_exc(), resp_body,
            exc_info=True
        )
        return JsonResponse(resp_body, status=500)


@login_required
def message_list(request):
    """消息列表"""
    messages_list = Message.objects.filter(robot__owner=request.user)
    
    # 筛选
    robot_id = request.GET.get('robot')
    direction = request.GET.get('direction')
    status = request.GET.get('status')
    
    if robot_id:
        messages_list = messages_list.filter(robot_id=robot_id)
    if direction:
        messages_list = messages_list.filter(direction=direction)
    if status:
        messages_list = messages_list.filter(status=status)
    
    # 分页
    paginator = Paginator(messages_list, 20)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    # 获取用户的所有机器人用于筛选
    robots = Robot.objects.filter(owner=request.user)
    
    context = {
        'page_obj': page_obj,
        'robots': robots,
        'current_robot': robot_id,
        'current_direction': direction,
        'current_status': status,
    }
    return render(request, 'robots/message_list.html', context)


# 管理员功能
def is_admin(user):
    """检查用户是否为管理员"""
    return hasattr(user, 'profile') and user.profile.is_admin


@login_required
def user_management(request):
    """用户管理（仅管理员）"""
    if not is_admin(request.user):
        messages.error(request, '您没有权限访问此页面')
        return redirect('dashboard')
    
    users = User.objects.all().order_by('-date_joined')
    
    context = {
        'users': users,
    }
    return render(request, 'robots/user_management.html', context)


@login_required
def user_create(request):
    """创建用户（仅管理员）"""
    if not is_admin(request.user):
        messages.error(request, '您没有权限访问此页面')
        return redirect('dashboard')
    
    if request.method == 'POST':
        form = UserCreateForm(request.POST)
        if form.is_valid():
            user = form.save()
            messages.success(request, f'用户 "{user.username}" 创建成功')
            return redirect('user_management')
    else:
        form = UserCreateForm()
    
    return render(request, 'robots/user_form.html', {
        'form': form,
        'action': '创建用户'
    })


@login_required
def user_edit(request, user_id):
    """编辑用户（仅管理员）"""
    if not is_admin(request.user):
        messages.error(request, '您没有权限访问此页面')
        return redirect('dashboard')
    
    user = get_object_or_404(User, id=user_id)
    
    if request.method == 'POST':
        form = UserEditForm(request.POST, instance=user)
        if form.is_valid():
            form.save()
            messages.success(request, f'用户 "{user.username}" 更新成功')
            return redirect('user_management')
    else:
        form = UserEditForm(instance=user)
    
    return render(request, 'robots/user_form.html', {
        'form': form,
        'user_obj': user,
        'action': '编辑用户'
    })


@login_required
def user_delete(request, user_id):
    """删除用户（仅管理员）"""
    if not is_admin(request.user):
        messages.error(request, '您没有权限访问此页面')
        return redirect('dashboard')
    
    user = get_object_or_404(User, id=user_id)
    
    # 不能删除自己
    if user == request.user:
        messages.error(request, '不能删除自己的账号')
        return redirect('user_management')
    
    if request.method == 'POST':
        username = user.username
        user.delete()
        messages.success(request, f'用户 "{username}" 已删除')
        return redirect('user_management')
    
    return render(request, 'robots/user_confirm_delete.html', {'user_obj': user})


# 日志管理功能
@login_required
def logs_viewer(request):
    """日志查看器页面"""
    logs_dir = settings.LOGS_DIR
    
    # 获取日志文件列表
    log_files = []
    if logs_dir.exists():
        for log_file in sorted(logs_dir.glob('*.log*'), key=lambda x: x.stat().st_mtime, reverse=True):
            try:
                stat = log_file.stat()
                log_files.append({
                    'name': log_file.name,
                    'size': stat.st_size,
                    'size_mb': round(stat.st_size / 1024 / 1024, 2),
                    'modified': datetime.fromtimestamp(stat.st_mtime),
                    'path': str(log_file.relative_to(settings.BASE_DIR))
                })
            except Exception:
                continue
    
    # 获取日志类型
    log_type = request.GET.get('type', 'django')
    lines = int(request.GET.get('lines', '100'))
    
    # 读取日志内容
    log_content = ""
    log_file_path = None
    
    if log_type == 'django':
        log_file_path = logs_dir / 'django.log'
    elif log_type == 'error':
        log_file_path = logs_dir / 'error.log'
    elif log_type == 'webhook':
        log_file_path = logs_dir / 'webhook.log'
    
    if log_file_path and log_file_path.exists():
        try:
            with open(log_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                # 读取最后N行
                all_lines = f.readlines()
                log_content = ''.join(all_lines[-lines:])
        except Exception as e:
            log_content = f"读取日志失败: {str(e)}"
    else:
        log_content = "日志文件不存在或暂无日志"
    
    context = {
        'log_files': log_files,
        'log_content': log_content,
        'current_type': log_type,
        'current_lines': lines,
        'total_files': len(log_files),
        'total_size_mb': round(sum(f['size'] for f in log_files) / 1024 / 1024, 2),
    }
    return render(request, 'robots/logs_viewer.html', context)


@login_required
def download_log(request, log_name):
    """下载单个日志文件"""
    logs_dir = settings.LOGS_DIR
    log_file = logs_dir / log_name
    
    # 安全检查：确保文件在logs目录中
    try:
        log_file = log_file.resolve()
        if not str(log_file).startswith(str(logs_dir.resolve())):
            messages.error(request, '无效的日志文件路径')
            return redirect('logs_viewer')
    except Exception:
        messages.error(request, '无效的日志文件')
        return redirect('logs_viewer')
    
    if not log_file.exists():
        messages.error(request, '日志文件不存在')
        return redirect('logs_viewer')
    
    try:
        with open(log_file, 'rb') as f:
            response = HttpResponse(f.read(), content_type='text/plain; charset=utf-8')
            response['Content-Disposition'] = f'attachment; filename="{log_name}"'
            return response
    except Exception as e:
        messages.error(request, f'下载日志失败: {str(e)}')
        return redirect('logs_viewer')


@login_required
def download_all_logs(request):
    """下载所有日志文件（打包为ZIP）"""
    logs_dir = settings.LOGS_DIR
    
    if not logs_dir.exists():
        messages.error(request, '日志目录不存在')
        return redirect('logs_viewer')
    
    # 创建ZIP文件
    zip_buffer = io.BytesIO()
    
    try:
        with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
            # 添加所有日志文件
            for log_file in logs_dir.glob('*.log*'):
                if log_file.is_file():
                    zip_file.write(log_file, arcname=log_file.name)
        
        # 生成文件名
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'wps_robot_logs_{timestamp}.zip'
        
        # 返回ZIP文件
        zip_buffer.seek(0)
        response = HttpResponse(zip_buffer.getvalue(), content_type='application/zip')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        return response
        
    except Exception as e:
        messages.error(request, f'打包日志失败: {str(e)}')
        return redirect('logs_viewer')


@login_required
def clear_logs(request):
    """清理旧日志文件"""
    if request.method != 'POST':
        return redirect('logs_viewer')
    
    logs_dir = settings.LOGS_DIR
    days = int(request.POST.get('days', '30'))
    
    if not logs_dir.exists():
        messages.warning(request, '日志目录不存在')
        return redirect('logs_viewer')
    
    try:
        cutoff_date = datetime.now() - timedelta(days=days)
        deleted_count = 0
        
        # 只删除轮转的日志文件（.log.1, .log.2等）
        for log_file in logs_dir.glob('*.log.*'):
            if log_file.is_file():
                file_mtime = datetime.fromtimestamp(log_file.stat().st_mtime)
                if file_mtime < cutoff_date:
                    log_file.unlink()
                    deleted_count += 1
        
        if deleted_count > 0:
            messages.success(request, f'已清理 {deleted_count} 个超过 {days} 天的旧日志文件')
        else:
            messages.info(request, f'没有超过 {days} 天的旧日志文件需要清理')
            
    except Exception as e:
        messages.error(request, f'清理日志失败: {str(e)}')
    
    return redirect('logs_viewer')


@login_required
def api_log_tail(request):
    """API: 实时获取日志尾部内容（用于AJAX轮询）"""
    log_type = request.GET.get('type', 'django')
    lines = int(request.GET.get('lines', '50'))
    
    logs_dir = settings.LOGS_DIR
    log_file_path = None
    
    if log_type == 'django':
        log_file_path = logs_dir / 'django.log'
    elif log_type == 'error':
        log_file_path = logs_dir / 'error.log'
    elif log_type == 'webhook':
        log_file_path = logs_dir / 'webhook.log'
    
    if log_file_path and log_file_path.exists():
        try:
            with open(log_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                all_lines = f.readlines()
                content = ''.join(all_lines[-lines:])
                return JsonResponse({
                    'success': True,
                    'content': content,
                    'lines': len(all_lines),
                    'file_size': log_file_path.stat().st_size
                })
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            }, status=500)
    else:
        return JsonResponse({
            'success': False,
            'error': '日志文件不存在'
        }, status=404)
