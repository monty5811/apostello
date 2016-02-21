from django.conf.urls import url

from site_config import views

urlpatterns = [
    url(
        r'^site/',
        views.SiteConfigView.as_view(),
        name='site'
    ),
    url(
        r'^responses/',
        views.ResponsesView.as_view(),
        name='responses'
    ),
]
