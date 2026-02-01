from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from .models import Robot, UserProfile


class RobotForm(forms.ModelForm):
    """机器人表单"""
    class Meta:
        model = Robot
        fields = ['name', 'webhook_url', 'description', 'hook_script', 'hook_script_file', 'max_message_count', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '输入机器人名称'}),
            'webhook_url': forms.URLInput(attrs={'class': 'form-control', 'placeholder': 'https://example.com/webhook'}),
            'description': forms.Textarea(attrs={'class': 'form-control', 'rows': 3, 'placeholder': '机器人描述'}),
            'hook_script': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '例如: example_hook'}),
            'hook_script_file': forms.FileInput(attrs={'class': 'form-control', 'accept': '.py'}),
            'max_message_count': forms.NumberInput(attrs={'class': 'form-control', 'min': 1, 'max': 1000, 'placeholder': '默认100，最大1000'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }
    
    def clean_max_message_count(self):
        """验证消息数量限制"""
        count = self.cleaned_data.get('max_message_count')
        if count < 1 or count > 1000:
            raise forms.ValidationError('消息记录数必须在1到1000之间')
        return count
    
    def clean_hook_script_file(self):
        """验证上传的脚本文件"""
        file = self.cleaned_data.get('hook_script_file')
        if file:
            if not file.name.endswith('.py'):
                raise forms.ValidationError('只能上传.py文件')
            # 检查文件大小（限制为1MB）
            if file.size > 1024 * 1024:
                raise forms.ValidationError('文件大小不能超过1MB')
        return file


class SendMessageForm(forms.Form):
    """发送消息表单"""
    msg_type = forms.ChoiceField(
        label='消息类型',
        choices=[
            ('text', '文本消息'),
            ('markdown', 'Markdown消息'),
            ('card', '卡片消息'),
        ],
        widget=forms.Select(attrs={'class': 'form-control'})
    )
    content = forms.CharField(
        label='消息内容',
        widget=forms.Textarea(attrs={
            'class': 'form-control', 
            'rows': 12, 
            'placeholder': '''输入消息内容

卡片消息：只需输入card部分的JSON，例如：
{
  "header": {
    "title": {
      "tag": "text",
      "content": {"type": "plainText", "text": "标题"}
    },
    "subtitle": {
      "tag": "text",
      "content": {"type": "plainText", "text": "副标题"}
    }
  },
  "elements": [
    {
      "tag": "text",
      "content": {"type": "plainText", "text": "内容"}
    }
  ],
  "i18n": {
    "zh-TW": {...},
    "en-US": {...}
  }
}

系统会自动添加 msgtype 字段'''
        }),
        required=False
    )
    
    # 卡片消息专用字段
    card_title = forms.CharField(
        label='卡片标题',
        required=False,
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': '卡片标题'})
    )
    card_text = forms.CharField(
        label='卡片内容',
        required=False,
        widget=forms.Textarea(attrs={'class': 'form-control', 'rows': 4, 'placeholder': '卡片内容'})
    )
    
    def clean(self):
        cleaned_data = super().clean()
        msg_type = cleaned_data.get('msg_type')
        content = cleaned_data.get('content')
        card_title = cleaned_data.get('card_title')
        card_text = cleaned_data.get('card_text')
        
        if msg_type == 'card':
            if not card_title and not content:
                raise forms.ValidationError('卡片消息必须提供标题或JSON内容')
        elif not content:
            raise forms.ValidationError('消息内容不能为空')
        
        return cleaned_data


class UserCreateForm(UserCreationForm):
    """创建用户表单"""
    is_admin = forms.BooleanField(
        label='管理员',
        required=False,
        widget=forms.CheckboxInput(attrs={'class': 'form-check-input'})
    )
    
    class Meta:
        model = User
        fields = ['username', 'password1', 'password2', 'email', 'is_admin']
        widgets = {
            'username': forms.TextInput(attrs={'class': 'form-control', 'placeholder': '用户名'}),
            'email': forms.EmailInput(attrs={'class': 'form-control', 'placeholder': '邮箱（可选）'}),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['password1'].widget.attrs.update({'class': 'form-control', 'placeholder': '密码'})
        self.fields['password2'].widget.attrs.update({'class': 'form-control', 'placeholder': '确认密码'})
    
    def save(self, commit=True):
        user = super().save(commit=False)
        if commit:
            user.save()
            # 创建用户配置
            UserProfile.objects.create(
                user=user,
                is_admin=self.cleaned_data.get('is_admin', False)
            )
        return user


class UserEditForm(forms.ModelForm):
    """编辑用户表单"""
    is_admin = forms.BooleanField(
        label='管理员',
        required=False,
        widget=forms.CheckboxInput(attrs={'class': 'form-check-input'})
    )
    new_password = forms.CharField(
        label='新密码',
        required=False,
        widget=forms.PasswordInput(attrs={'class': 'form-control', 'placeholder': '留空则不修改密码'})
    )
    
    class Meta:
        model = User
        fields = ['username', 'email', 'is_active']
        widgets = {
            'username': forms.TextInput(attrs={'class': 'form-control'}),
            'email': forms.EmailInput(attrs={'class': 'form-control'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if hasattr(self.instance, 'profile'):
            self.fields['is_admin'].initial = self.instance.profile.is_admin
    
    def save(self, commit=True):
        user = super().save(commit=False)
        new_password = self.cleaned_data.get('new_password')
        if new_password:
            user.set_password(new_password)
        
        if commit:
            user.save()
            # 更新用户配置
            profile, created = UserProfile.objects.get_or_create(user=user)
            profile.is_admin = self.cleaned_data.get('is_admin', False)
            profile.save()
        
        return user
