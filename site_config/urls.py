from django.conf.urls import url

from site_config import views

urlpatterns = [
    url(
        r'^site/',
        views.SiteConfigView.as_view(),
        name='site',
    ),
    url(
        r'^responses/',
        views.ResponsesView.as_view(),
        name='responses',
    ),
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
