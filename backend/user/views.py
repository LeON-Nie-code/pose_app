import json
from http import HTTPStatus
from json import JSONDecodeError

from django.contrib import auth
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404
from django.urls import reverse

from . import constraint, models
from .models import Friendship


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

    code = ''
    # TODO 生成并发送验证码
    request.session.update(
        {'username': data.username, 'password': data.password, 'mobile': data.mobile, 'verification_code': code,
         'operation_to_complete': 'register'})
    request.session.set_expiry(80)  # 一定时间内不验证就清零。留了些富余。
    request.session.save()
    return HttpResponse(status=200)


def login(request):
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)
    if request.user:
        return HttpResponse('已登录', status=HTTPStatus.BAD_REQUEST)

    try:
        data = constraint.LoginMsg(json.loads(request.body))
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    user = auth.authenticate(username=data.username, password=data.password)
    if user is None:
        return HttpResponse('验证不通过', status=HTTPStatus.BAD_REQUEST)

    auth.login(request, user)
    return JsonResponse({}, status=HTTPStatus.OK)


@login_required
def logout(request):
    if request.method != 'POST':
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)

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
            for friendship in user.friendship_set.all():
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
            if not user.friendship_set.filter(Q(userA=other) | Q(userB=other)).exists():
                user.friendship_set.create(userA=user, userB=other)
            return HttpResponse(status=200)
        elif request.method == 'DELETE':
            get_object_or_404(user.friendship_set, Q(userA=other) | Q(userB=other)).delete()
            return HttpResponse(status=200)
        elif request.method == 'POST':
            try:
                friendship = user.friendship_set.get(Q(userA=other) | Q(userB=other), waiting=True)
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
        args = {
            'username': request.session['username'],
            'password': request.session['password'],
            'mobile': request.session['mobile'],
        }
        if data['username'] != args['username']:
            return HttpResponse('用户名对不上', status=HTTPStatus.INTERNAL_SERVER_ERROR)

        # 担心IO操作被KeyError打断，特地隔离。
        new_user = models.User.objects.create_user(**args)
        models.Profile.objects.create(user=new_user)
        auth.login(request, new_user)

    return HttpResponse(status=200)
