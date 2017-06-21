from django.conf.urls import url
from django.contrib.auth.models import User
from rest_framework.permissions import IsAuthenticated

from api import drf_permissions as p
from api import serializers as s
from api import views as v
from apostello import forms as f
from apostello import models as m
from elvanto.models import ElvantoGroup

# api
urlpatterns = [
    # list views:
    url(
        r'^v2/sms/in/$',
        v.SmsCollection.as_view(
            model_class=m.SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeIncoming)
        ),
        name='in_log'
    ),
    url(
        r'^v2/sms/out/$',
        v.Collection.as_view(
            model_class=m.SmsOutbound,
            serializer_class=s.SmsOutboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeOutgoing),
            related_field='recipient',
        ),
        name='out_log'
    ),
    url(
        r'^v2/recipients/(?:(?P<pk>\d+)/)?$',
        v.Collection.as_view(
            model_class=m.Recipient,
            form_class=f.RecipientForm,
            serializer_class=s.RecipientSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeContactNames)
        ),
        name='recipients'
    ),
    url(r'^v2/recipients/import/csv/$', v.CSVImport.as_view(), name='recipients_import_csv'),
    url(
        r'^v2/groups/(?:(?P<pk>\d+)/)?$',
        v.Collection.as_view(
            model_class=m.RecipientGroup,
            form_class=f.ManageRecipientGroupForm,
            serializer_class=s.RecipientGroupSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeGroups),
            prefetch_fields=['recipient_set'],
        ),
        name='recipient_groups'
    ),
    url(
        r'^v2/elvanto/groups/$',
        v.Collection.as_view(
            model_class=ElvantoGroup,
            serializer_class=s.ElvantoGroupSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeGroups, p.CanImport)
        ),
        name='elvanto_groups'
    ),
    url(
        r'^v2/queued/sms/$',
        v.QueuedSmsCollection.as_view(
            model_class=m.QueuedSms,
            serializer_class=s.QueuedSmsSerializer,
            permission_classes=(IsAuthenticated, p.IsStaff)
        ),
        name='queued_smss'
    ),
    url(
        r'^v2/keywords/(?:(?P<keyword>\w+)/)?$',
        v.Collection.as_view(
            model_class=m.Keyword,
            form_class=f.KeywordForm,
            serializer_class=s.KeywordSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeKeywords),
            prefetch_fields=[
                'linked_groups',
                'owners',
                'subscribed_to_digest',
            ],
        ),
        name='keywords'
    ),
    url(
        r'^v2/users/profiles/$',
        v.Collection.as_view(
            model_class=m.UserProfile,
            form_class=f.UserProfileForm,
            serializer_class=s.UserProfileSerializer,
            permission_classes=(IsAuthenticated, p.IsStaff),
        ),
        name='user_profiles'
    ),
    url(
        r'^v2/users/$',
        v.UserCollection.as_view(
            model_class=User,
            serializer_class=s.UserSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeKeywords),
        ),
        name='users'
    ),
    url(
        r'^v2/config/$',
        v.ConfigView.as_view(),
        name='site_config',
    ),
    url(
        r'^v2/responses/$',
        v.ResponsesView.as_view(),
        name='default_responses',
    ),
    # simple toggle views:
    url(
        r'^v2/toggle/sms/in/display_on_wall/(?P<pk>[0-9]+)/$',
        v.ObjSimpleUpdate.as_view(
            model_class=m.SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeIncoming),
            field='display_on_wall',
        ),
        name='toggle_display_on_wall',
    ),
    url(
        r'^v2/toggle/sms/in/deal_with/(?P<pk>[0-9]+)/$',
        v.ObjSimpleUpdate.as_view(
            model_class=m.SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeIncoming, p.CanSeeKeywords),
            field='dealt_with',
        ),
        name='toggle_deal_with_sms',
    ),
    url(
        r'^v2/toggle/elvanto/group/sync/(?P<pk>[0-9]+)/$',
        v.ObjSimpleUpdate.as_view(
            model_class=ElvantoGroup,
            serializer_class=s.ElvantoGroupSerializer,
            permission_classes=(IsAuthenticated, ),
            field='sync',
        ),
        name='toggle_elvanto_group_sync',
    ),
    # action views:
    url(
        r'^v2/actions/sms/send/adhoc/$',
        v.SendAdhoc.as_view(),
        name='act_send_adhoc',
    ),
    url(
        r'^v2/actions/sms/send/group/$',
        v.SendGroup.as_view(),
        name='act_send_group',
    ),
    url(
        r'^v2/actions/sms/in/archive/(?P<pk>[0-9]+)/$',
        v.ArchiveObj.as_view(
            model_class=m.SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeIncoming, ),
        ),
        name='act_archive_sms',
    ),
    url(
        r'^v2/actions/recipient/archive/(?P<pk>[0-9]+)/$',
        v.ArchiveObj.as_view(
            model_class=m.Recipient, serializer_class=s.RecipientSerializer, permission_classes=(IsAuthenticated, )
        ),
        name='act_archive_recipient',
    ),
    url(
        r'^v2/actions/group/archive/(?P<pk>[0-9]+)/$',
        v.ArchiveObj.as_view(
            model_class=m.RecipientGroup,
            serializer_class=s.RecipientGroupSerializer,
            permission_classes=(IsAuthenticated, )
        ),
        name='act_archive_group',
    ),
    url(
        r'^v2/actions/keyword/archive/(?P<keyword>[\d|\w]+)/$',
        v.ArchiveObj.as_view(
            model_class=m.Keyword, serializer_class=s.KeywordSerializer, permission_classes=(IsAuthenticated, )
        ),
        name='act_archive_keyword',
    ),
    url(
        r'^v2/actions/keywords/(?P<keyword>[\d|\w]+)/archive_resps/$',
        v.ArchiveAllResponses.as_view(),
        name='act_keyword_archive_all_responses',
    ),
    url(
        r'^v2/actions/sms/in/reingest/(?P<pk>[0-9]+)/$',
        v.ReingestObj.as_view(
            model_class=m.SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeIncoming),
        ),
        name='act_reingest_sms',
    ),
    url(
        r'^v2/actions/group/update_members/(?P<pk>[0-9]+)/$',
        v.UpdateGroupMembers.as_view(
            model_class=m.RecipientGroup,
            serializer_class=s.RecipientGroupSerializer,
            permission_classes=(IsAuthenticated, p.CanSeeGroups)
        ),
        name='act_update_group_members'
    ),
    url(r'^v2/actions/elvanto/group_fetch/$', v.ElvantoFetchButton.as_view(), name='act_fetch_elvanto_groups'),
    url(r'^v2/actions/elvanto/group_pull/$', v.ElvantoPullButton.as_view(), name='act_pull_elvanto_groups'),
    url(
        r'^v2/actions/queued/sms/(?P<pk>[0-9]+)/$',
        v.CancelObj.as_view(
            model_class=m.QueuedSms,
            serializer_class=s.QueuedSmsSerializer,
            permission_classes=(IsAuthenticated, p.IsStaff)
        ),
        name='act_cancel_queued_sms'
    ),
    url(
        r'^v2/actions/users/profiles/update/(?P<pk>[0-9]+)/$',
        v.UpdateUserProfile.as_view(
            model_class=m.UserProfile,
            serializer_class=s.UserProfileSerializer,
            permission_classes=(IsAuthenticated, p.IsStaff),
        ),
        name='user_profile_update'
    ),
    url(
        r'^v2/actions/group/create_all/$',
        v.CreateAllGroup.as_view(),
        name='act_create_all_group',
    ),
    # api setup
    url(r'^v2/setup/$', v.SetupView.as_view(), name='setup'),
]
