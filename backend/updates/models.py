from django.db import models

from user.models import User


# Create your models here.

class Comment(models.Model):
    class Meta:
        db_table = 'comment'

    text = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def to_obj(self):
        return {
            'text': self.text,
            'author': self.author.username,
        }


def post_image_path(instance, filename):
    """假设动态已经创建"""
    return f'update_images/{instance.author.id}/{instance.id}/{filename}'


class Post(models.Model):
    class Meta:
        db_table = 'post'

    text = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    n_image = models.IntegerField(default=0)
    image0 = models.ImageField(upload_to=post_image_path, null=True)
    image1 = models.ImageField(upload_to=post_image_path, null=True)
    image2 = models.ImageField(upload_to=post_image_path, null=True)
    image3 = models.ImageField(upload_to=post_image_path, null=True)

    comments = models.ManyToManyField(Comment, blank=True)
    likes = models.IntegerField(default=0)
