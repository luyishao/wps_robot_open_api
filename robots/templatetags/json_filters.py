import json
from django import template
from django.utils.safestring import mark_safe

register = template.Library()


@register.filter(name='prettyjson')
def prettyjson(value):
    """将JSON数据格式化为美观的字符串"""
    if value is None:
        return ''
    try:
        if isinstance(value, str):
            value = json.loads(value)
        return json.dumps(value, indent=2, ensure_ascii=False, sort_keys=True)
    except (ValueError, TypeError):
        return str(value)
