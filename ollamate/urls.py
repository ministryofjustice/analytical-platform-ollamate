from django.contrib import admin
from django.urls import include, path

from streamingapp.views import redirect_to_ollama

urlpatterns = [
    path("admin/", admin.site.urls),
    path(
        "azure_auth/",
        include("azure_auth.urls"),
    ),
    path("stream/", include("streamingapp.urls")),
    path("", redirect_to_ollama),
]
