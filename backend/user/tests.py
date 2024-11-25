from http import HTTPStatus

from django.test import TestCase, Client
from django.urls import reverse

from .models import User

# Create your tests here.

class TestUser(TestCase):
    def setUp(self):
        self.client = Client()
        User.objects.create_user(username='neo', mobile='18529630741', password='one')

    def test_login(self):
        response = self.client.post(
            reverse('login'),
            {'username': 'oracle', 'password': '<PASSWORD>'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST)
        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': '<PASSWORD>'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST)
        response = self.client.post(
            reverse('login'),
            {'username': 'neo', 'password': 'one'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.OK)

    def test_register(self):
        response = self.client.post(
            reverse('register'),
            {'username': 'victor', 'password': 'vector', 'mobile': '14703692581'},
            content_type='application/json')
        self.assertEqual(response.status_code, HTTPStatus.OK)
        response = self.client.post(
            reverse('login'),
            {'username': 'victor', 'password': 'vector', 'mobile': '14703692581'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, HTTPStatus.OK)

        response = self.client.post(
            reverse('login'),
            {'username': 'victor', 'password': 'vector'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, HTTPStatus.OK)
