from django.urls import path

from user import views

urlpatterns = [
    path('register', views.register, name='register'),
    path('verify', views.verify),
    path('login', views.login, name='login'),
    path('logout', views.logout, name='logout'),
    path('profile', views.profile),
    path('profile/<field>', views.profile),
    path('friend', views.friend),
    path('friend/<userid>', views.friend),
]
