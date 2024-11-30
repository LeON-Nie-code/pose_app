from django.urls import path

from records import views

urlpatterns = [
    path('<userid>', views.new_record),
]
