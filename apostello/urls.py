# -*- coding: utf-8 -*-
from allauth.account.views import PasswordChangeView
from django.conf.urls import include, url
from django.contrib import admin
from django.views.generic import TemplateView

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
            template_name="apostello/index.html",
            required_perms=[]
        ),
        name='index'
    ),
    url(
        r'not_approved/$',
        TemplateView.as_view(template_name='apostello/not_approved.html'),
        name='not_approved'
    ),
    url(
        r'^help/$',
        v.SimpleView.as_view(
            template_name="apostello/help.html",
            required_perms=[]
        ),
        name='help'
    ),
    url(
        r'^send/adhoc/',
        v.SendAdhoc.as_view(required_perms=['can_send_sms']),
        name='send_adhoc'
    ),
    url(
        r'^send/group/',
        v.SendGroup.as_view(required_perms=['can_send_sms']),
        name='send_group'
    ),
]
# recipient group urls
urlpatterns += [
    url(
        r'^group/all/$',
        v.SimpleView.as_view(
            template_name='apostello/groups.html',
            required_perms=['can_see_groups']
        ),
        name='recipient_groups'
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
]

# recipient urls
urlpatterns += [
    url(
        r'^recipient/all/$',
        v.SimpleView.as_view(
            template_name='apostello/recipients.html',
            required_perms=['can_see_contact_names']
        ),
        name='recipients'
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
            required_perms=['can_see_keywords']
        ),
        name='keywords',
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
        r'^keyword/responses/(?P<pk>\d+)/archive/$',
        v.keyword_responses,
        {'archive': True},
        name='keyword_responses_archive'
    ),
    url(
        r'^keyword/responses/csv/(?P<pk>\d+)/$',
        v.keyword_csv,
        name='keyword_csv'
    ),
    url(
        r'^keyword/responses/wall/(?P<pk>\d+)/$',
        v.keyword_wall,
        name='keyword_wall'
    ),
    url(
        r'^keyword/responses/curate_wall/(?P<pk>\d+)/$',
        v.keyword_wall_curate,
        name='keyword_wall_curator'
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
    ), url(
        r'^incoming/wall/$',
        v.SimpleView.as_view(
            template_name='apostello/wall.html',
            required_perms=['can_see_incoming']
        ),
        name='incoming_wall'
    ), url(
        r'^incoming/curate_wall/$',
        v.SimpleView.as_view(
            template_name='apostello/wall_curator.html',
            required_perms=['can_see_incoming']
        ),
        name='incoming_wall_curator'
    ), url(
        r'^outgoing/$',
        v.SimpleView.as_view(
            template_name='apostello/outgoing.html',
            required_perms=['can_see_outgoing']
        ),
        name='outgoing'
    )
]

# import urls
urlpatterns += [
    url(
        r'^recipient/import/$',
        v.import_recipients,
        name='import_recipients'
    ),
]
urlpatterns += [
    url(
        r'^elvanto/',
        include(
            'elvanto.urls',
            namespace='elvanto'
        )
    )
]

# twilio api url
urlpatterns += [url(r'^sms/$', v.sms)]

# auth and admin
urlpatterns += [
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
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
    url(
        r'^graphs/',
        include(
            'graphs.urls',
            namespace='graphs'
        )
    ),
    url(
        r'^api/',
        include(
            'api.urls',
            namespace='api'
        )
    ),
]
