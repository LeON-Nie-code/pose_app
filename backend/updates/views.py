import json
from http import HTTPStatus

from django.contrib.auth.decorators import login_required
from django.http import JsonResponse, HttpResponse

from updates import models


# Create your views here.

@login_required
def release_post(request):
    data = json.loads(request.body)
    content = data['content']

    blog = models.Post(
        content=content,
        author=request.user,
    )
    blog.save()
    return JsonResponse({'pk': blog.pk})


@login_required
def make_comment(request):
    data = json.loads(request.body)
    content = data['content']
    post_key = data['to']

    comment = models.Comment(content=content, author=request.user)
    comment.save()
    models.Post.objects.get(pk=post_key).comments.add(comment)
    return HttpResponse('Succeed', status=HTTPStatus.OK)
