from django.conf.urls import url

from elvanto.views import ImportView

urlpatterns = [
    url(
        r'import/$',
        ImportView.as_view(required_perms=['can_import']),
        name='import'
    ),
]
