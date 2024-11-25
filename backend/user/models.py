import django.contrib.auth.models
from django.db import models

# Create your models here.

class User(django.contrib.auth.models.AbstractUser):
    class Meta:
        db_table = 'user'

    mobile = models.CharField(max_length=11, unique=True)


class Profile(models.Model):
    class Meta:
        db_table = 'profile'

    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    peers = models.ManyToManyField(User, blank=True, related_name='peers')
