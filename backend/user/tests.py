import json
from http import HTTPStatus

from django.conf import settings
from django.test import TestCase, Client
from django.urls import reverse

from .models import User, Friendship, Profile


# Create your tests here.

class TestUser(TestCase):
    def setUp(self):
        settings.USE_SMS_VERIFICATION = True
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
            {'username': 'victor', 'password': 'vector', 'mobile': '18101375056'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.OK)
        code = input('验证码：')
        response = self.client.post(
            reverse('verify'),
            {'code': code, 'username': 'victor'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        # 成功登录
        response = self.client.post(
            reverse('login'),
            {'username': 'victor', 'password': 'vector'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, HTTPStatus.OK)
        # 成功登出
        response = self.client.post(reverse('logout'))
        self.assertEqual(response.status_code, HTTPStatus.OK)

    def tearDown(self):
        User.objects.all().delete()
        settings.USE_SMS_VERIFICATION = False


class TestFriends(TestCase):
    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='neo', password='one', mobile='18529630741')
        User.objects.create_user(username='victor', password='vector', mobile='14703692581')

    def test_invite(self):
        # 未登录直接操作
        response = self.client.put(reverse('friend_user', args=['neo']))
        self.assertNotIn(response.status_code, (202, 404), msg=response.context)

        self.client.login(username='neo', password='one')
        # 邀请错了人
        response = self.client.put(reverse('friend_user', args=['knuth']))
        self.assertEqual(response.status_code, 404)
        # 邀请成功
        response = self.client.put(reverse('friend_user', args=['victor']))
        self.assertEqual(response.status_code, 202)
        # 未经对方邀请
        response = self.client.post(reverse('friend_user', args=['victor']))
        self.assertEqual(response.status_code, 400)
        self.client.logout()

        self.client.login(username='victor', password='vector')
        # 进入待通过好友列表
        response = self.client.get(reverse('friend'))
        self.assertEqual(response.status_code, 200, msg=response.context)
        self.assertIn('neo', json.loads(response.content)['applying'])
        # 未受邀便试图通过
        response = self.client.post(reverse('friend_user', args=['knuth']))
        self.assertEqual(response.status_code, 404)
        # 成功通过，更新好友列表
        response = self.client.post(reverse('friend_user', args=['neo']))
        self.assertEqual(response.status_code, 200)
        response = self.client.get(reverse('friend'))
        self.assertIn('neo', json.loads(response.content)['offline'])
        self.client.logout()

        self.client.login(username='neo', password='one')
        # 申请通过，更新好友列表
        response = self.client.get(reverse('friend'))
        self.assertIn('victor', json.loads(response.content)['offline'])
        self.client.logout()

    def test_break(self):
        if not Friendship.objects.exists():
            Friendship.objects.create(userA=User.objects.get(username='neo'), userB=User.objects.get(username='victor'))
        self.client.login(username='neo', password='one')
        # 删除未知好友
        response = self.client.delete(reverse('friend_user', args=['knuth']))
        self.assertEqual(response.status_code, 404)
        # 删除好友成功
        response = self.client.delete(reverse('friend_user', args=['victor']))
        self.assertEqual(response.status_code, 200, response.context)
        response = self.client.post(reverse('logout'))

    def tearDown(self):
        Friendship.objects.all().delete()
        User.objects.all().delete()


class TestProfile(TestCase):
    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='neo', password='one')
        Profile.objects.create(user=User.objects.get(username='neo'))
        self.client.login(username='neo', password='one')

    def test_read(self):
        user = User.objects.get(username='neo')
        profile = user.profile
        data = {
            'name': 'hero',
            'school': 'Tsinghua',
            'gender': 'F',
            'email': 'hello@mails.tsinghau.edu.cn'
        }
        profile.nickname = data['name']
        profile.institution = data['school']
        profile.gender = data['gender']
        profile.email = data['email']
        profile.save()
        response = self.client.get(reverse('profile'))
        self.assertEqual(response.status_code, 200, msg=response.context)
        resp_body = json.loads(response.content)
        self.assertTrue(all(resp_body[k] == data[k] for k in data))

    def test_update(self):
        response = self.client.patch(
            reverse('profile'),
            {'school': 'Bilibili'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        profile = Profile.objects.get(user=User.objects.get(username='neo'))
        self.assertEqual(profile.institution, 'Bilibili')
