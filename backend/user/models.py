import django.contrib.auth.models
from django.db import models


# Create your models here.

class User(django.contrib.auth.models.AbstractUser):
    class Meta:
        db_table = 'user'

    mobile = models.CharField(max_length=11, unique=True)

    online = models.BooleanField(default=False)


class Friendship(models.Model):
    class Meta:
        db_table = 'friendship'

    userA = models.ForeignKey(User, on_delete=models.CASCADE, related_name='friendships_asA')
    userB = models.ForeignKey(User, on_delete=models.CASCADE, related_name='friendships_asB')

    waiting = models.BooleanField(default=True)


def avatar_path(instance, filename):
    return f'avatars/{instance.user.id}/{filename}'


class Profile(models.Model):
    class Meta:
        db_table = 'profile'

    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)

    # peers = models.ManyToManyField(User, blank=True, related_name='peers')
    avatar = models.ImageField(upload_to=avatar_path)
    nickname = models.CharField(max_length=11, default='')
    institution = models.CharField(max_length=11, default='')
    gender = models.CharField(max_length=6, default='')
    email = models.EmailField(unique=True, default='')
