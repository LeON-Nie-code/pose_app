from django.db import models

from user.models import User

# Create your models here.

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
