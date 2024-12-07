import json

from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404

from records import models
from records.models import load_record, dump_record
from user.models import User


# Create your views here.

@login_required
def new_record(request, userid):
    data = json.loads(request.body)

    record = models.Entry()
    record.user = request.user

    load_record(record, data)

    record.save()
    return


def raw_record(request, user_id, record_id):
    if request.method == 'GET':
        if user_id == request.user.username:
            user = request.user
        else:
            user = get_object_or_404(User, username=user_id)
            if not (request.user.friendships_asA.filter(userB=user) | request.user.friendships_asB.filter(userA=user)):
                return HttpResponse(status=404)
        record = get_object_or_404(user.entry_set, pk=record_id)
        data = {
            'record': dump_record(record),
            'taken_at': record.taken_at,
        }
        return JsonResponse(data)
