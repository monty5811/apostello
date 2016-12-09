# -*- coding: utf-8 -*-
from allauth.account.views import PasswordChangeView
from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin

from apostello import views as v
from apostello.decorators import keyword_access_check
from apostello.forms import (
    KeywordForm, ManageRecipientGroupForm, RecipientForm
)
from apostello.models import Keyword, Recipient, RecipientGroup

admin.autodiscover()

# index and two sending views, dashboard
urlpatterns = [
    url(
        r'^$',
        v.SimpleView.as_view(
            template_name="apostello/index.html", required_perms=[]
        ),
        name='index'
    ),
    url(r'not_approved/$', v.NotApprovedView.as_view(), name='not_approved'),
    url(
        r'^help/$',
        v.SimpleView.as_view(
            template_name="apostello/help.html", required_perms=[]
        ),
        name='help'
    ),
    url(
        r'^send/adhoc/$',
        v.SendAdhoc.as_view(required_perms=['can_send_sms']),
        name='send_adhoc'
    ),
    url(
        r'^send/group/$',
        v.SendGroup.as_view(required_perms=['can_send_sms']),
        name='send_group'
    ),
    url(
        r'^usage/$',
        v.SimpleView.as_view(
            template_name='apostello/usage_dashboard.html',
        ),
        name='usage_summary',
    ),
]
# recipient group urls
urlpatterns += [
    url(
        r'^group/all/$',
        v.SimpleView.as_view(
            template_name='apostello/groups.html',
            required_perms=['can_see_groups'],
            rest_uri='/api/v1/groups/',
        ),
        name='recipient_groups'
    ),
    url(
        r'^group/archive/$',
        v.SimpleView.as_view(
            template_name='apostello/groups.html',
            rest_uri='/api/v1/groups_archive/',
        ),
        name='recipient_groups_archive'
    ),
    url(
        r'^group/new/$',
        v.ItemView.as_view(
            model_class=RecipientGroup,
            form_class=ManageRecipientGroupForm,
            redirect_url='recipient_groups',
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
            redirect_url='recipient_groups',
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
        r'^group/composer/$',
        v.SimpleView.as_view(
            template_name='apostello/group_composer.html',
            rest_uri='/api/v1/groups/',
            required_perms=['can_see_groups', 'can_see_contact_names']
        ),
        name='group_composer'
    ),
]

# recipient urls
urlpatterns += [
    url(
        r'^recipient/all/$',
        v.SimpleView.as_view(
            template_name='apostello/recipients.html',
            required_perms=['can_see_contact_names'],
            rest_uri='/api/v1/recipients/',
        ),
        name='recipients'
    ),
    url(
        r'^recipient/archive/$',
        v.SimpleView.as_view(
            template_name='apostello/recipients.html',
            rest_uri='/api/v1/recipients_archive/',
        ),
        name='recipients_archive'
    ),
    url(
        r'^recipient/new/$',
        v.ItemView.as_view(
            model_class=Recipient,
            form_class=RecipientForm,
            redirect_url='recipients',
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
            redirect_url='recipients',
            identifier='recipient',
            required_perms=['can_see_contact_names', 'can_see_contact_nums']
        ),
        name='recipient'
    ),
]

# keyword urls
urlpatterns += [
    url(
        r'^keyword/all/$',
        v.SimpleView.as_view(
            template_name='apostello/keywords.html',
            required_perms=['can_see_keywords'],
            rest_uri='/api/v1/keywords/',
        ),
        name='keywords',
    ),
    url(
        r'^keyword/archive/$',
        v.SimpleView.as_view(
            template_name='apostello/keywords.html',
            rest_uri='/api/v1/keywords_archive/',
        ),
        name='keywords_archive',
    ),
    url(
        r'^keyword/new/$',
        v.ItemView.as_view(
            model_class=Keyword,
            form_class=KeywordForm,
            redirect_url='keywords',
            identifier='keyword',
            required_perms=['can_see_keywords']
        ),
        name='keyword'
    ),
    url(
        r'^keyword/edit/(?P<pk>\d+)/$',
        keyword_access_check(
            v.ItemView.as_view(
                model_class=Keyword,
                form_class=KeywordForm,
                redirect_url='keywords',
                identifier='keyword',
                required_perms=['can_see_keywords']
            )
        ),
        name='keyword'
    ),
    url(
        r'^keyword/responses/(?P<pk>\d+)/$',
        v.keyword_responses,
        name='keyword_responses'
    ),
    url(
        r'^keyword/responses/archive/(?P<pk>\d+)/$',
        v.keyword_responses, {'archive': True},
        name='keyword_responses_archive'
    ),
    url(
        r'^keyword/responses/csv/(?P<pk>\d+)/$',
        v.keyword_csv,
        name='keyword_csv'
    ),
]

# log urls
urlpatterns += [
    url(
        r'^incoming/$',
        v.SimpleView.as_view(
            template_name='apostello/incoming.html',
            required_perms=['can_see_incoming']
        ),
        name='incoming'
    ),
    url(
        r'^incoming/wall/$',
        v.SimpleView.as_view(
            template_name='apostello/wall.html',
            required_perms=['can_see_incoming']
        ),
        name='incoming_wall'
    ),
    url(
        r'^incoming/curate_wall/$',
        v.SimpleView.as_view(
            template_name='apostello/wall_curator.html',
            required_perms=['can_see_incoming']
        ),
        name='incoming_wall_curator'
    ),
    url(
        r'^outgoing/$',
        v.SimpleView.as_view(
            template_name='apostello/outgoing.html',
            required_perms=['can_see_outgoing']
        ),
        name='outgoing'
    ),
    url(
        r'^scheduled/sms/$',
        v.SimpleView.as_view(
            template_name='apostello/scheduled_sms.html', required_perms=[]
        ),
        name='scheduled_sms'
    ),
]

# import urls
urlpatterns += [
    url(
        r'^recipient/import/$',
        v.ImportRecipients.as_view(),
        name='import_recipients'
    ),
]
urlpatterns += [
    url(r'^elvanto/', include(
        'elvanto.urls', namespace='elvanto'
    ))
]

# twilio api url
urlpatterns += [url(r'^sms/$', v.sms)]

# auth and admin
urlpatterns += [
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
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
    url(
        r'^users/profiles/$',
        v.SimpleView.as_view(
            template_name='apostello/users.html',
        ),
        name='user_profile_table'
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
]

# debu toolbar
if settings.DEBUG:
    import debug_toolbar
    urlpatterns += [url(r'^__debug__/', include(debug_toolbar.urls)), ]
