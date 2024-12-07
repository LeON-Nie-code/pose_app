from django.urls import path

from records import views

urlpatterns = [
    path('new', views.new_record),
    path('<user_id>/<record_id>', views.raw_record),
]
