import django.contrib.auth.models
from django.db import models

# Create your models here.

class User(django.contrib.auth.models.User):
    class Meta:
        db_table = 'user'

    mobile = models.CharField(max_length=11, unique=True)


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    peers = models.ManyToManyField(User, blank=True, related_name='peers')


class Comment(models.Model):
    class Meta:
        db_table = 'comment'

    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)


class Post(models.Model):
    class Meta:
        db_table = 'post'

    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    comments = models.ManyToManyField(Comment, blank=True)
    likes = models.IntegerField(default=0)
