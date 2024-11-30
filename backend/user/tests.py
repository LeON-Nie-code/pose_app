import json
from http import HTTPStatus

from django.test import TestCase, Client
from django.urls import reverse

from .models import User, Friendship


# Create your tests here.

class TestUser(TestCase):
    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='neo', mobile='18529630741', password='one')

    def test_login_logout(self):
        # 未注册用户登录
        response = self.client.post(
            reverse('login'),
            {'username': 'oracle', 'password': '<PASSWORD>'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST)
        # 密码错误
        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': '<PASSWORD>'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST)
        # 成功登录
        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': 'one'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.OK)

        # 成功登出
        response = self.client.post(reverse('logout'))
        self.assertEqual(response.status_code, HTTPStatus.OK)
        # 未登录就登出
        response = self.client.post(reverse('logout'))
        self.assertNotEqual(response.status_code, HTTPStatus.OK)

    def test_register(self):
        # 成功注册
        response = self.client.post(
            reverse('register'),
            {'username': 'victor', 'password': 'vector', 'mobile': '14703692581'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.OK)
        # 成功登录
        response = self.client.post(
            reverse('login'),
            {'username': 'victor', 'password': 'vector', 'mobile': '14703692581'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, HTTPStatus.OK)
        # 成功登出
        response = self.client.post(reverse('logout'))
        self.assertEqual(response.status_code, HTTPStatus.OK)

    def tearDown(self):
        User.objects.all().delete()


class TestFriends(TestCase):
    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='neo', password='one', mobile='18529630741')
        User.objects.create_user(username='victor', password='vector', mobile='14703692581')

    def test_invite(self):
        # 未登录直接操作
        response = self.client.put('user/friend/neo')
        self.assertNotIn(response.status_code, (202, 404))

        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': 'one'},
            content_type='application/json'
        )
        # 邀请错了人
        response = self.client.put('user/friend/knuth')
        self.assertEqual(response.status_code, 404)
        # 邀请成功
        response = self.client.put('user/friend/victor')
        self.assertEqual(response.status_code, 202)
        # 未经对方通过
        response = self.client.post('user/friend/victor')
        self.assertEqual(response.status_code, 400)
        response = self.client.post(reverse('logout'))

        response = self.client.post(
            reverse('login'),
            {'username': 'victor', 'password': 'vector'},
            content_type='application/json'
        )
        # 进入待通过好友列表
        response = self.client.get('user/friend')
        self.assertEqual(response.status_code, 200)
        self.assertIn('neo', json.loads(response.content['applying']))
        # 未受邀便试图通过
        response = self.client.post('user/friend/knuth')
        self.assertEqual(response.status_code, 404)
        # 成功通过，更新好友列表
        response = self.client.put('user/friend/victor')
        self.assertEqual(response.status_code, 200)
        response = self.client.get('user/friend')
        self.assertIn('neo', json.loads(response.content['offline']))
        response = self.client.post(reverse('logout'))

        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': 'one'},
            content_type='application/json'
        )
        # 申请通过，更新好友列表
        response = self.client.get('user/friend')
        self.assertIn('victor', json.loads(response.content['offline']))
        response = self.client.post(reverse('logout'))

    def test_break(self):
        if not Friendship.objects.exists():
            Friendship.objects.create(userA=User.objects.get(username='neo'), userB=User.objects.get(username='victor'))
        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': 'one'},
            content_type='application/json'
        )
        # 删除未知好友
        response = self.client.delete('user/friend/knuth')
        self.assertEqual(response.status_code, 404)
        # 删除好友成功
        response = self.client.delete('user/friend/victor')
        self.assertEqual(response.status_code, 202)
        response = self.client.post(reverse('logout'))

    def tearDown(self):
        Friendship.objects.all().delete()
        User.objects.all().delete()
