import json
from http import HTTPStatus
from json import JSONDecodeError

from django.http import HttpResponse

from . import constraint, controller
# Create your views here.

def register(request):
    if request.method != 'POST':
        return HttpResponse('Use POST method', status=HTTPStatus.METHOD_NOT_ALLOWED)

    try:
        data = json.loads(request.body)
        data = constraint.RegisterMsg(data)
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    try:
        controller.register(data)
    except Exception as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    return HttpResponse(json.dumps({'login': '/user/login/'}), status=HTTPStatus.OK)


def login(request):
    if request.method != 'POST':
        return HttpResponse('Use POST method', status=HTTPStatus.METHOD_NOT_ALLOWED)

    try:
        data = json.loads(request.body)
        data = constraint.LoginMsg(data)
    except JSONDecodeError:
        return HttpResponse('Invalid JSON', status=HTTPStatus.BAD_REQUEST)
    except ValueError as e:
        return HttpResponse(str(e), status=HTTPStatus.BAD_REQUEST)

    if controller.login(data) is None:
        return HttpResponse('Authentication failed', status=HTTPStatus.OK)

    return HttpResponse('Succeed', status=HTTPStatus.OK)