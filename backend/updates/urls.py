from django.urls import path

from updates import views

urlpatterns = [
    path('post', views.release_post, name='post'),
    path('comment', views.make_comment, name='comment'),
]