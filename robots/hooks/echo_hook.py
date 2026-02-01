"""
Echo Hook - 简单回显消息的示例
"""


def process_message(robot, message_data):
    """
    回显接收到的消息
    """
    msg_type = message_data.get('msg_type', 'text')
    
    if msg_type == 'text':
        content = message_data.get('content', {})
        text = content.get('text', '')
        
        # 返回相同的消息
        return {
            "msg_type": "text",
            "content": {
                "text": f"[回显] {text}"
            }
        }
    
    # 其他类型消息返回提示
    return {
        "msg_type": "text",
        "content": {
            "text": f"收到 {msg_type} 类型的消息"
        }
    }
