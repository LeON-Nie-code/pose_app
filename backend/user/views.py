import json
from http import HTTPStatus
from json import JSONDecodeError

from django.conf import settings
from django.contrib import auth
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404
from django.urls import reverse

import user
from . import constraint, models
from .models import Friendship, User


def register(request):
    """
    接受JSON内容的POST请求，将信息存入会话，并发送验证码。
    """
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)

    try:
        data = constraint.RegisterMsg(json.loads(request.body))
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    if settings.USE_SMS_VERIFICATION:
        code = ''
        # TODO 生成并发送验证码
        request.session.update(
            {'username': data.username, 'password': data.password, 'mobile': data.mobile, 'verification_code': code,
             'operation_to_complete': 'register'})
        request.session.set_expiry(80)  # 一定时间内不验证就清零。留了些富余。
        request.session.save()
        return HttpResponse(status=200)
    else:
        User.objects.create_user(username=data.username, password=data.password, mobile=data.mobile)
        return HttpResponse(status=200)


def login(request):
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)
    if request.user.is_authenticated:
        return HttpResponse('已登录')

    try:
        data = constraint.LoginMsg(json.loads(request.body))
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=400)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    the_user = auth.authenticate(username=data.username, password=data.password)
    if the_user is None:
        return HttpResponse('验证不通过', status=400)

    auth.login(request, the_user)
    the_user.online = True
    the_user.save()
    return JsonResponse({})


@login_required
def logout(request):
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)

    request.user.online = False
    request.user.save()
    auth.logout(request)
    return HttpResponse(status=HTTPStatus.OK)


@login_required
def profile(request, field=''):
    info = request.user.profile
    if request.method == 'GET':
        if field == '':
            data = {'avatar': reverse('profile', kwargs={'field': 'avatar'}), }
            if info.nickname:
                data['name'] = info.nickname
            if info.email:
                data['email'] = info.email
            if info.institution:
                data['school'] = info.institution
            if info.gender:
                data['gender'] = info.gender
            return JsonResponse(data)
        elif field == 'avatar':
            if info.avatar:
                with info.avatar.open('rb') as f:
                    data = f.read()
                return HttpResponse(data, content_type='image/png')
            else:
                return HttpResponse(status=404)

        return HttpResponse(status=400)
    elif request.method == 'PATCH':
        data = json.loads(request.body)
        data = constraint.ProfileMsg(data)
        for k, v in data.items():
            setattr(info, k, v)
        info.save()
        return HttpResponse(status=200)
    return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)


@login_required
def friend(request, userid=None):
    user = request.user

    if userid is None:
        if request.method == 'GET':
            data = {'online': [], 'offline': [], 'applying': []}
            for friendship in (user.friendships_asA.all() | user.friendships_asB.all()):
                # TODO 瓶颈
                other = friendship.userB
                if other == user:
                    other = friendship.userA

                if friendship.waiting:
                    data['applying'].append(other.username)
                elif other.is_active:
                    data['online'].append(other.username)
                else:
                    data['offline'].append(other.username)
            return JsonResponse(data, status=200)

        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)
    else:
        other = get_object_or_404(models.User, username=userid)
        if request.method == 'PUT':
            if not user.friendships_asA.exists() and not user.friendships_asB.exists():
                user.friendships_asA.create(userA=user, userB=other)
            return HttpResponse(status=200)

        elif request.method == 'DELETE':
            get_object_or_404(
                user.friendships_asA.all() | user.friendships_asB.all(),
                Q(userA=other) | Q(userB=other)).delete()
            return HttpResponse(status=200)

        elif request.method == 'POST':
            try:
                friendship = (user.friendships_asA.all() | user.friendships_asB.all()).get(
                    Q(userA=other) | Q(userB=other), waiting=True)
                friendship.waiting = False
                return HttpResponse(status=200)
            except Friendship.DoesNotExist:
                return HttpResponse(status=400)

        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)


def verify(request):
    """
    获得客户端发送的验证码，通过则创建用户。
    自动登录。
    """
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)

    code = request.session['verification_code']
    verify_for = request.session['operation_to_complete']
    data = json.loads(request.body)
    if data['code'] != code:
        return HttpResponse(status=403)

    if verify_for == 'register':
        args = {'username': request.session['username'], 'password': request.session['password'],
                'mobile': request.session['mobile'], }
        if data['username'] != args['username']:
            return HttpResponse('用户名对不上', status=HTTPStatus.INTERNAL_SERVER_ERROR)

        # 担心IO操作被KeyError打断，特地隔离。
        new_user = models.User.objects.create_user(**args)
        models.Profile.objects.create(user=new_user)
        auth.login(request, new_user)

    return HttpResponse(status=200)
