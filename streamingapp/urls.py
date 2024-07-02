from django.urls import path
from . import views

urlpatterns = [
    path("call-ollama/", views.call_ollama, name="call_ollama"),
]
