from allauth.account.views import PasswordChangeView
from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.views.generic.base import TemplateView

from apostello import views as v
from apostello.decorators import keyword_access_check
from apostello.forms import (
    KeywordForm, ManageRecipientGroupForm, RecipientForm
)
from apostello.models import Keyword, Recipient, RecipientGroup

admin.autodiscover()

urlpatterns = [
    url(r'^sw(.*.js)$', v.sw_js, name='sw_js'),
    url(r'not_approved/$', v.NotApprovedView.as_view(), name='not_approved'),
    url(
        r'^help/$',
        v.SimpleView.as_view(
            template_name="apostello/help.html", required_perms=[]
        ),
        name='help'
    ),
    url(
        r'^usage/$',
        v.SimpleView.as_view(
            template_name='apostello/usage_dashboard.html',
        ),
        name='usage_summary',
    ),
    url(
        r'^group/new/$',
        v.ItemView.as_view(
            model_class=RecipientGroup,
            form_class=ManageRecipientGroupForm,
            redirect_url='/group/all/',
            identifier='group',
            required_perms=['can_see_groups']
        ),
        name='group'
    ),
    url(
        r'^group/edit/(?P<pk>\d+)/$',
        v.ItemView.as_view(
            model_class=RecipientGroup,
            form_class=ManageRecipientGroupForm,
            redirect_url='/group/all/',
            identifier='group',
            required_perms=['can_see_groups']
        ),
        name='group'
    ),
    url(
        r'^group/create_all/$',
        v.CreateAllGroupView.as_view(),
        name='group_create_all',
    ),
    url(
        r'^recipient/new/$',
        v.ItemView.as_view(
            model_class=Recipient,
            form_class=RecipientForm,
            redirect_url='/recipient/all/',
            identifier='recipient',
            required_perms=['can_see_contact_names']
        ),
        name='recipient'
    ),
    url(
        r'^recipient/edit/(?P<pk>\d+)/$',
        v.ItemView.as_view(
            model_class=Recipient,
            form_class=RecipientForm,
            redirect_url='/recipient/all/',
            identifier='recipient',
            required_perms=['can_see_contact_names', 'can_see_contact_nums']
        ),
        name='recipient'
    ),
    url(
        r'^keyword/new/$',
        v.ItemView.as_view(
            model_class=Keyword,
            form_class=KeywordForm,
            redirect_url='/keyword/all/',
            identifier='keyword',
            required_perms=['can_see_keywords']
        ),
        name='keyword'
    ),
    url(
        r'^keyword/edit/(?P<keyword>[\d|\w]+)/$',
        keyword_access_check(
            v.ItemView.as_view(
                model_class=Keyword,
                form_class=KeywordForm,
                redirect_url='/keyword/all/',
                identifier='keyword',
                required_perms=['can_see_keywords']
            )
        ),
        name='keyword'
    ),
    url(
        r'^keyword/responses/csv/(?P<keyword>[\d|\w]+)/$',
        v.keyword_csv,
        name='keyword_csv'
    ),
    url(
        r'^recipient/import/$',
        v.ImportRecipients.as_view(),
        name='import_recipients'
    ),
]

# twilio api url
urlpatterns += [url(r'^sms/$', v.sms)]

# auth and admin
urlpatterns += [
    url(r'^admin/', include(admin.site.urls)),
    # auth-setup
    url(
        r'^api-setup/$',
        v.APISetupView.as_view(),
        name='api-setup',
    ),
    # edit user profiles
    url(
        r'^users/profiles/(?P<pk>\d+)/$',
        v.UserProfileView.as_view(),
        name='user_profile_form'
    ),
    # over ride success url:
    url(
        r"^accounts/password/change/$",
        PasswordChangeView.as_view(success_url='/'),
        name="account_change_password"
    ),
    url(r'^accounts/', include('allauth.urls')),
]
# apps etc
urlpatterns += [
    url(r'^config/', include(
        'site_config.urls', namespace='site_config'
    )),
    url(r'^graphs/', include(
        'graphs.urls', namespace='graphs'
    )),
    url(r'^api/', include(
        'api.urls', namespace='api'
    )),
    url(r'^api-docs/', include('rest_framework_docs.urls')),
    url(
        r'^offline/$',
        TemplateView.as_view(template_name="apostello/offline.html"),
        name='offline',
    ),
    url(
        r'^.*$',
        v.SimpleView.as_view(
            template_name="apostello/spa.html", required_perms=[]
        ),
        name='spa'
    ),
]

# debu toolbar
if settings.DEBUG:
    import debug_toolbar
    urlpatterns += [url(r'^__debug__/', include(debug_toolbar.urls)), ]
