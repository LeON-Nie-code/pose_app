from django.test import TestCase, Client
from .models import User

# Create your tests here.

class TestUser(TestCase):
    def setUp(self):
        self.client = Client()
        # self.user = User.objects.create_user(username='neo', email='18529630741', password='one')

    def test_login(self):
        response = self.client.post('/login/', {'username': 'neo', 'password': 'one'})
        print(response.content)
        self.assertEqual(response.status_code, 200)

    def test_register(self):
        response = self.client.post('/register/', {'username': 'victor', 'password': 'vector', 'mobile': '14703692581'})
        self.assertEqual(response.status_code, 200)

        response = self.client.post('/login/', {'username': 'victor', 'password': 'vector'})
        self.assertEqual(response.status_code, 200)

    def tearDown(self):
        pass