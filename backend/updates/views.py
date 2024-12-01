import json
from http import HTTPStatus

from django.contrib.auth.decorators import login_required
from django.core.files.base import ContentFile
from django.http import JsonResponse, HttpResponse
from django.shortcuts import get_object_or_404
from django.urls import reverse

from updates import models


# Create your views here.

@login_required
def release_post(request):
    data = json.loads(request.body)
    if data['n_image'] >= 4:
        return HttpResponse(status=400)
    blog = models.Post(text=data['text'], author=request.user, n_image=data['n_image'], )
    blog.save()

    return HttpResponse(blog.pk)


@login_required
def visit_post(request, update_id):
    if request.method == 'GET':
        update = get_object_or_404(request.user.post_set, pk=update_id)

        data = {'text': update.text, 'comments': [c.to_obj() for c in update.comments.all()], 'likes': update.likes,
                'images': [reverse('update:image', kwargs={'update_id': update_id, 'index': i}) for i in
                           range(update.n_image)], }
        return JsonResponse(data)
    elif request.method == 'DELETE':
        get_object_or_404(request.user.post_set, pk=update_id).delete()
        return HttpResponse(status=200)
    return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)


@login_required
def picture(request, update_id, index):
    update = get_object_or_404(request.user.post_set, pk=update_id)
    if not index in range(update.n_image):
        return HttpResponse(status=400)
    if request.method == 'GET':
        with getattr(update, f'image{index}').open('rb') as img:
            data = img.read()
        return HttpResponse(status=200, content=data, content_type='image/png')
    elif request.method == 'PUT':
        data = request.body
        img_field = getattr(update, f'image{index}')
        if img_field is not None:
            img_field.delete(save=False)
        img_field.save(name=f'{index}.png', content=ContentFile(data), save=True)
        return HttpResponse(status=200)
    return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)


@login_required
def comment(request, update_id, comment_id=None):
    update = get_object_or_404(models.Post, pk=update_id)
    if comment_id is None:
        if request.method == 'POST':
            data = json.loads(request.body)
            text = data['text']
            author = models.User.objects.get(username=data['author'])
            update.comments.create(author=author, text=text)
            return HttpResponse(status=200)
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)
    else:
        if request.method == 'DELETE':
            cmt = get_object_or_404(models.Comment, pk=comment_id)
            cmt.delete()
            return HttpResponse(status=200)
        return HttpResponse(status=HTTPStatus.METHOD_NOT_ALLOWED)