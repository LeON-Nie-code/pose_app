from django.urls import path

from user import views

urlpatterns = [
    path('register', views.register, name='register'),
    path('verify', views.verify, name='verify'),
    path('login', views.login, name='login'),
    path('logout', views.logout, name='logout'),
    path('profile', views.profile, name='profile'),
    path('profile/<field>', views.profile, name='profile'),
    path('friend', views.friend, name='friend'),
    path('friend/<userid>', views.friend, name='friend_user'),
]
