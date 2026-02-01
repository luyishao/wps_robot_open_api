"""
示例Hook脚本

当机器人接收到webhook消息时，会调用此脚本的process_message函数
"""
import requests


def process_message(robot, message_data):
    """
    处理webhook接收到的消息
    
    参数：
        robot: 机器人对象（Robot模型实例）
        message_data: webhook POST的数据（字典格式）
    
    返回：
        dict: 要返回给WPS的响应数据（可选）
    """
    print(f"[Hook] 机器人 {robot.name} 收到消息")
    print(f"[Hook] 消息数据: {message_data}")
    
    # 示例1: 简单的消息处理
    msg_type = message_data.get('msg_type', '')
    
    if msg_type == 'text':
        content = message_data.get('content', {})
        text = content.get('text', '')
        print(f"[Hook] 收到文本消息: {text}")
        
        # 可以在这里处理消息，比如：
        # - 保存到数据库
        # - 触发其他业务逻辑
        # - 调用第三方API
        
        # 返回响应消息（可选）
        return {
            "msg_type": "text",
            "content": {
                "text": f"已收到您的消息: {text}"
            }
        }
    
    # 示例2: 如果配置了webhook_url，可以转发消息
    if robot.webhook_url:
        try:
            response = requests.post(
                robot.webhook_url,
                json=message_data,
                timeout=5
            )
            print(f"[Hook] 消息转发结果: {response.status_code}")
        except Exception as e:
            print(f"[Hook] 消息转发失败: {e}")
    
    # 不返回任何内容或返回None表示只返回标准的success响应
    return None


def custom_function():
    """
    你可以定义其他辅助函数
    """
    pass
