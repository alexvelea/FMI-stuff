from django.contrib import admin
from django.urls import path, include
from django.contrib.auth.decorators import login_required
from . import views


urlpatterns = [
    path('dashboard/<str:username>', views.dashboard, name='dashboard'),
    path('', views.index, name='index'),
]
