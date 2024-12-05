from django.urls import path

from updates import views

urlpatterns = [
    path('post', views.release_post, name='post'),
    path('<update_id>', views.visit_post),
    path('<update_id>/image/<int:index>', views.picture, name="update-image"),
    path('<update_id>/comment', views.comment, name='comment'),
    path('<update_id>/comment/<comment_id>', views.comment)
]
