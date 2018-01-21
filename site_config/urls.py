from django.conf.urls import url

from site_config import views

app_name = 'site_config'

urlpatterns = [
    url(
        r'^first_run/',
        views.FirstRunView.as_view(),
        name='first_run',
    ),
    url(
        r'send_test_email/',
        views.TestEmailView.as_view(),
        name='test_email',
    ),
    url(
        r'send_test_sms/',
        views.TestSmsView.as_view(),
        name='test_sms',
    ),
    url(
        r'create_admin_user/',
        views.CreateSuperUser.as_view(),
        name='create_super_user',
    ),
]
