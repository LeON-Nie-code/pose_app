import io
import json
import random

import PIL.Image
from django.test import TestCase, Client

from user.models import User


# Create your tests here.

class TestPost(TestCase):
    """
    测试独立动态的发送和删除。
    """

    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='alice', mobile='13000000001', password='one')
        self.client.login(username='alice', password='one')

    def test_raw(self):
        """
        纯文字动态
        :return:
        """
        content = 'hello'

        # 不能创建不合格的动态
        response = self.client.post(
            '/updates/post',
            {'text': content, 'n_image': 9},
            content_type='application/json',
            follow=True
        )
        self.assertEqual(response.status_code, 400, msg=response.content)

        # 创建动态
        response = self.client.post(
            '/updates/post',
            {'text': content, 'n_image': 0},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200, msg=response.content)
        update_id = response.content.decode('utf-8')

        # 成功读取动态
        response = self.client.get(
            f'/updates/{update_id}',
        )
        self.assertEqual(response.status_code, 200, msg=response.content)
        body = json.loads(response.content)
        self.assertEqual(body['text'], content, msg='动态内容不一致')

        # 只能删除自己的动态
        response = self.client.delete(
            f'/updates/{update_id}0',
        )
        self.assertEqual(response.status_code, 404, msg=response.content)

        # 成功删除动态
        response = self.client.delete(
            f'/updates/{update_id}',
        )
        self.assertEqual(response.status_code, 200, msg=response.content)

    def test_image(self):
        """
        图片上传和下载
        :return:
        """
        n_image = 3
        response = self.client.post(
            f'/updates/post',
            {'text': 'hello', 'n_image': n_image},
            content_type='application/json',
            follow=True
        )
        update_id = response.content.decode('utf-8')

        # 不能越界
        response = self.client.put(
            f'/updates/{update_id}/image/{-1}',
        )
        self.assertNotEqual(response.status_code, 200, msg=response.content)
        response = self.client.put(
            f'/updates/{update_id}/image/{3}',
        )
        self.assertEqual(response.status_code, 400)

        # 成功上传
        def generate_png(size: tuple[int, int]) -> PIL.Image:
            return PIL.Image.new('RGB', size, color=(random.randint(0, 255),) * 3)

        images = [
            generate_png((200, 200))
            for _ in range(n_image)
        ]
        for i, img in enumerate(images):
            with io.BytesIO() as stream:
                img.save(stream, format='PNG')
                binary = stream.getvalue()
            response = self.client.put(
                f'updates/{update_id}/image/{i}',
                binary,
                content_type='image/png',
            )
            self.assertEqual(response.status_code, 200, msg=response.context)

        # 成功访问
        for i, img in enumerate(images):
            response = self.client.get(
                f'/updates/{update_id}/image/{i}',
            )
            self.assertEqual(response.status_code, 200, msg=response.content)
            self.assertEqual(response.content_type, 'image/png')
            self.assertEqual(PIL.Image.open(response.content), img)

    def tearDown(self):
        self.client.logout()
        User.objects.all().delete()


class TestComment(TestCase):
    """
    评论的上传、查看、删除。
    """

    def setUp(self):
        self.clientA = Client()
        User.objects.create_user(username='alice', mobile='12345678901', password='A')
        self.clientA.login(username='alice', password='A')

        self.clientB = Client()
        User.objects.create_user(username='bob', mobile='12345678902', password='B')
        self.clientB.login(username='bob', password='B')

    def test_add(self):
        response = self.clientA.post(
            '/updates/post',
            {'text': 'foo', 'n_image': 0},
            content_type='application/json',
        )
        update_id = response.content.decode('utf-8')

        # 由他人添加多条评论
        comments = ('你好', 'hello', 'aloha')
        for c in comments:
            response = self.clientB.post(
                f'/updates/{update_id}/comment',
                {'text': c},
                content_type='application/json',
            )
            self.assertEqual(response.status_code, 200, msg=response.context)
        # 阅读别人的评论
        response = self.clientA.get(
            f'/updates/{update_id}',
        )
        body = json.loads(response.content)
        for old, new in zip(comments, body['comments']):
            self.assertEqual(old, new['text'], msg='评论内容不一致')

    def test_delete(self):
        response = self.clientA.post(
            '/updates/post',
            {'text': 'bar', 'n_image': 0},
            content_type='application/json',
        )
        update_id = response.content.decode('utf-8')
        response = self.clientA.post(
            f'updates/{update_id}/comment',
            {'text': 'happy!'},
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 200, msg=response.context)
        comment_id = response.content.decode('utf-8')

        # 别人删除
        response = self.clientB.delete(
            f'/updates/{update_id}/comment/{comment_id}',
        )
        self.assertEqual(response.status_code, 404, msg=response.content)

        # 自己删除
        response = self.clientA.delete(
            f'/updates/{update_id}/comment/{comment_id}',
        )
        self.assertEqual(response.status_code, 200, msg=response.context)

        # 验证
        response = self.clientA.get(
            f'/updates/{update_id}',
        )
        comments = json.loads(response.content)['comments']
        self.assertNotIn(comment_id, (c['id'] for c in comments), msg=comments)

    def tearDown(self):
        self.clientA.logout()
        self.clientB.logout()
        User.objects.all().delete()
