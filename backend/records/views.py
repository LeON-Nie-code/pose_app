import json

from django.contrib.auth.decorators import login_required

from records import models
from records.models import load_record


# Create your views here.

@login_required
def new_record(request, userid):
    data = json.loads(request.body)

    record = models.Entry()
    record.user = request.user

    load_record(record, data)

    record.save()
    return
