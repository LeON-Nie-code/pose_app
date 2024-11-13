from django.contrib.auth import authenticate

from . import models, constraint

def register(params: constraint.RegisterMsg):
    user = models.User.objects.create_user(params.username, params.mobile, params.password)
    user.save()
    return user

def login(params: constraint.LoginMsg):
    user = authenticate(username=params.username, password=params.password)
    return user