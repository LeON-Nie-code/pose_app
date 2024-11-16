import json
from http import HTTPStatus
from json import JSONDecodeError

from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, JsonResponse
from django.contrib import auth
from django.urls import reverse

from . import constraint, models
# Create your views here.


def register(request):
    try:
        data = constraint.RegisterMsg(json.loads(request.body))
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    try:
        models.User.objects.create_user(
            username=data.username, password=data.password, mobile=data.mobile
        )
    except Exception as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    return JsonResponse({'login': reverse(login)})


def login(request):
    try:
        data = constraint.LoginMsg(json.loads(request.body))
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    user = auth.authenticate(username=data.username, password=data.password)
    if user is None:
        return HttpResponse('Authentication failed', status=HTTPStatus.OK)

    auth.login(request, user)
    return HttpResponse('Succeed', status=HTTPStatus.OK)


@login_required
def logout(request):
    auth.logout(request)
    return HttpResponse('Succeed', status=HTTPStatus.OK)


@login_required
def release_post(request):
    data = json.loads(request.body)
    content = data['content']

    blog = models.Post(
        content=content,
        author=models.User.objects.get(username=request.user.username)
    )
    blog.save()
    return JsonResponse({'pk': blog.pk})


@login_required
def make_comment(request):
    data = json.loads(request.body)
    content = data['content']
    post_key = data['to']

    comment = models.Comment(content=content, author=models.User.objects.get(username=request.user.username))
    comment.save()
    models.Post.objects.get(pk=post_key).comments.add(comment)
    return HttpResponse('Succeed', status=HTTPStatus.OK)
