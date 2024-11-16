from django.contrib.auth import authenticate

from . import models, constraint

def register(params: constraint.RegisterMsg):
    user = models.User.objects.create_user(
        username=params.username,
        password=params.password,
        mobile=params.mobile,
    )
    user.save()
    return user

def login(params: constraint.LoginMsg):
    user = authenticate(
        username=params.username,
        password=params.password
    )
    return user

def logout(params: constraint.LogoutMsg):
    pass