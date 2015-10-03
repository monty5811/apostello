# -*- coding: utf-8 -*-
from django.conf.urls import include, url
from django.contrib import admin

from apostello.decorators import keyword_access_check
from apostello.forms import (KeywordForm, ManageRecipientGroupForm,
                             RecipientForm)
from apostello.models import Keyword, Recipient, RecipientGroup
from apostello.views import (ElvantoImportView, ItemView, SendAdhoc, SendGroup,
                             SimpleView)

admin.autodiscover()
# index and two sending views, dashboard
urlpatterns = [
    url(r'^$', SimpleView.as_view(template_name="apostello/index.html", required_perms=[]), name='index'),
    url(r'^help/$', SimpleView.as_view(template_name="apostello/help.html", required_perms=[]), name='help'),
    url(r'^send/adhoc/', SendAdhoc.as_view(required_perms=['can_send_sms']), name='send_adhoc'),
    url(r'^send/group/', SendGroup.as_view(required_perms=['can_send_sms']), name='send_group'),
]
# recipient group urls
urlpatterns += [
    url(r'^group/all/$', SimpleView.as_view(template_name='apostello/groups.html', required_perms=['can_see_groups']), name='recipient_groups'),
    url(r'^group/new/$',
        ItemView.as_view(
            model_class=RecipientGroup,
            form_class=ManageRecipientGroupForm,
            redirect_url='recipient_groups',
            identifier='group',
            required_perms=['can_see_groups']),
        name='group'),
    url(r'^group/edit/(?P<pk>\d+)/$',
        ItemView.as_view(
            model_class=RecipientGroup,
            form_class=ManageRecipientGroupForm,
            redirect_url='recipient_groups',
            identifier='group',
            required_perms=['can_see_groups']),
        name='group'),
]

# recipient urls
urlpatterns += [
    url(r'^recipient/all/$', SimpleView.as_view(template_name='apostello/recipients.html', required_perms=['can_see_contact_names']), name='recipients'),
    url(r'^recipient/new/$',
        ItemView.as_view(
            model_class=Recipient,
            form_class=RecipientForm,
            redirect_url='recipients',
            identifier='recipient',
            required_perms=['can_see_contact_names']),
        name='recipient'),
    url(r'^recipient/edit/(?P<pk>\d+)/$',
        ItemView.as_view(
            model_class=Recipient,
            form_class=RecipientForm,
            redirect_url='recipients',
            identifier='recipient',
            required_perms=['can_see_contact_names', 'can_see_contact_nums']),
        name='recipient'),
]

# keyword urls
urlpatterns += [
    url(r'^keyword/all/$', SimpleView.as_view(template_name='apostello/keywords.html', required_perms=['can_see_keywords']), name='keywords'),
    url(r'^keyword/new/$',
        ItemView.as_view(
            model_class=Keyword,
            form_class=KeywordForm,
            redirect_url='keywords',
            identifier='keyword',
            required_perms=['can_see_keywords']),
        name='keyword'),
    url(r'^keyword/edit/(?P<pk>\d+)/$',
        keyword_access_check(
            ItemView.as_view(
                model_class=Keyword,
                form_class=KeywordForm,
                redirect_url='keywords',
                identifier='keyword',
                required_perms=['can_see_keywords'])),
        name='keyword'),
    url(r'^keyword/responses/(?P<pk>\d+)/$', 'apostello.views.keyword_responses', name='keyword_responses'),
    url(r'^keyword/responses/(?P<pk>\d+)/archive/$', 'apostello.views.keyword_responses', {'archive': True}, name='keyword_responses_archive'),
    url(r'^keyword/responses/csv/(?P<pk>\d+)/$', 'apostello.views.keyword_csv', name='keyword_csv'),
    url(r'^keyword/responses/wall/(?P<pk>\d+)/$', 'apostello.views.keyword_wall', name='keyword_wall'),
    url(r'^keyword/responses/curate_wall/(?P<pk>\d+)/$', 'apostello.views.keyword_wall_curate', name='keyword_wall_curator'),
]

# log urls
urlpatterns += [
    url(r'^incoming/$', SimpleView.as_view(template_name='apostello/incoming.html', required_perms=['can_see_incoming']), name='incoming'),
    url(r'^incoming/wall/$', 'apostello.views.wall', name='incoming_wall'),
    url(r'^incoming/curate_wall/$', 'apostello.views.wall_curate', name='incoming_wall_curator'),
    url(r'^outgoing/$', SimpleView.as_view(template_name='apostello/outgoing.html', required_perms=['can_see_outgoing']), name='outgoing')
]

# import urls
urlpatterns += [
    url(r'^recipient/import/$', 'apostello.views.import_recipients', name='import_recipients'),
    url(r'^elvanto/import/$', ElvantoImportView.as_view(required_perms=['can_import']), name='import_elvanto'),
]

# twilio api url
urlpatterns += [
    url(r'^sms/$', 'apostello.views.sms')
]

# auth and admin
urlpatterns += [
    url(r'^admin/', include(admin.site.urls)),
    url('', include('social.apps.django_app.urls', namespace='social')),
]
# apps etc
urlpatterns += [
    url(r'^graphs/', include('graphs.urls', namespace='graphs')),
    url(r'^api/', include('api.urls', namespace='api')),
]
