from django.test import TestCase
from django.contrib.auth.models import User
from .models import Robot, Message, UserProfile


class RobotModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        UserProfile.objects.create(user=self.user, is_admin=False)
    
    def test_robot_creation(self):
        """测试创建机器人"""
        robot = Robot.objects.create(
            name='test_robot',
            owner=self.user,
            webhook_url='https://example.com/webhook',
            is_active=True
        )
        self.assertEqual(robot.name, 'test_robot')
        self.assertEqual(robot.owner, self.user)
        self.assertTrue(robot.is_active)
    
    def test_robot_str(self):
        """测试机器人字符串表示"""
        robot = Robot.objects.create(
            name='test_robot',
            owner=self.user
        )
        self.assertEqual(str(robot), 'testuser/test_robot')


class MessageModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        UserProfile.objects.create(user=self.user, is_admin=False)
        self.robot = Robot.objects.create(
            name='test_robot',
            owner=self.user
        )
    
    def test_message_creation(self):
        """测试创建消息"""
        message = Message.objects.create(
            robot=self.robot,
            direction='incoming',
            content={'text': 'test message'},
            status='success'
        )
        self.assertEqual(message.robot, self.robot)
        self.assertEqual(message.direction, 'incoming')
        self.assertEqual(message.status, 'success')
