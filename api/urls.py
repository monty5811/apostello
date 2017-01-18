from django.conf.urls import url
from rest_framework.permissions import IsAuthenticated

from api import serializers as s
from api import views as v
from api.drf_permissions import (
    CanImport, CanSeeContactNames, CanSeeGroups, CanSeeIncoming, CanSeeKeyword,
    CanSeeKeywords, CanSeeOutgoing, IsStaff
)
from apostello.models import (
    Keyword, QueuedSms, Recipient, RecipientGroup, SmsInbound, SmsOutbound,
    UserProfile
)
from elvanto.models import ElvantoGroup

# api
urlpatterns = [
    # user profiles
    url(
        r'^v1/users/profiles/$',
        v.ApiCollection.as_view(
            model_class=UserProfile,
            serializer_class=s.UserProfileSerializer,
            permission_classes=(IsAuthenticated, IsStaff),
        ),
        name='user_profiles'
    ),
    url(
        r'^v1/users/profiles/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=UserProfile,
            serializer_class=s.UserProfileSerializer,
            permission_classes=(IsAuthenticated, IsStaff),
        ),
        name='user_profiles_member'
    ),
    # sms views
    url(
        r'^v1/sms/in/$',
        v.ApiCollection.as_view(
            model_class=SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, CanSeeIncoming)
        ),
        name='in_log'
    ),
    url(
        r'^v1/sms/out/$',
        v.ApiCollection.as_view(
            model_class=SmsOutbound,
            serializer_class=s.SmsOutboundSerializer,
            permission_classes=(IsAuthenticated, CanSeeOutgoing),
            related_field='recipient',
        ),
        name='out_log'
    ),
    url(
        r'^v1/sms/live_wall/all/$',
        v.ApiCollectionAllWall.as_view(
            permission_classes=(IsAuthenticated, CanSeeIncoming)
        ),
        name='live_wall_all'
    ),
    url(
        r'^v1/sms/in/recpient/(?P<pk>\d+)/$',
        v.ApiCollectionRecentSms.as_view(
            permission_classes=(
                IsAuthenticated, CanSeeContactNames, CanSeeIncoming
            )
        ),
        name='contact_recent_sms'
    ),
    url(
        r'^v1/sms/in/keyword/(?P<pk>\d+)/$',
        v.ApiCollectionKeywordSms.as_view(
            permission_classes=(
                IsAuthenticated, CanSeeKeywords, CanSeeKeyword, CanSeeIncoming
            ),
            archive=False
        ),
        name='keyword_sms'
    ),
    url(
        r'^v1/sms/in/keyword/(?P<pk>\d+)/archive/$',
        v.ApiCollectionKeywordSms.as_view(
            permission_classes=(
                IsAuthenticated, CanSeeKeywords, CanSeeKeyword, CanSeeIncoming
            ),
            archive=True
        ),
        name='keyword_sms_archive'
    ),
    url(
        r'^v1/sms/in/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=SmsInbound,
            serializer_class=s.SmsInboundSerializer,
            permission_classes=(IsAuthenticated, CanSeeIncoming),
        ),
        name='sms_in_member'
    ),
    # recipient views
    url(
        r'^v1/recipients/$',
        v.ApiCollection.as_view(
            model_class=Recipient,
            serializer_class=s.RecipientSerializer,
            filter_list=True,
            filters={'is_archived': False},
            permission_classes=(IsAuthenticated, CanSeeContactNames)
        ),
        name='recipients'
    ),
    url(
        r'^v1/recipients_archive/$',
        v.ApiCollection.as_view(
            model_class=Recipient,
            serializer_class=s.RecipientSerializer,
            filter_list=True,
            filters={'is_archived': True},
            permission_classes=(IsAuthenticated, IsStaff)
        ),
        name='recipients_archive'
    ),
    url(
        r'^v1/recipients/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=Recipient,
            serializer_class=s.RecipientSerializer,
            permission_classes=(IsAuthenticated, CanSeeContactNames)
        ),
        name='recipient'
    ),
    # group views
    url(
        r'^v1/groups/$',
        v.ApiCollection.as_view(
            model_class=RecipientGroup,
            serializer_class=s.RecipientGroupSerializer,
            filter_list=True,
            filters={'is_archived': False},
            permission_classes=(IsAuthenticated, CanSeeGroups),
            prefetch_fields=['recipient_set'],
        ),
        name='recipient_groups'
    ),
    url(
        r'^v1/groups_archive/$',
        v.ApiCollection.as_view(
            model_class=RecipientGroup,
            serializer_class=s.RecipientGroupSerializer,
            filter_list=True,
            filters={'is_archived': True},
            permission_classes=(IsAuthenticated, IsStaff),
        ),
        name='recipient_groups_archive'
    ),
    url(
        r'^v1/groups/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=RecipientGroup,
            serializer_class=s.RecipientGroupSerializer,
            permission_classes=(IsAuthenticated, CanSeeGroups)
        ),
        name='group'
    ),
    # Elvanto groups
    url(
        r'^v1/elvanto/groups/$',
        v.ApiCollection.as_view(
            model_class=ElvantoGroup,
            serializer_class=s.ElvantoGroupSerializer,
            permission_classes=(IsAuthenticated, CanSeeGroups, CanImport)
        ),
        name='elvanto_groups'
    ),
    url(
        r'^v1/elvanto/group/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=ElvantoGroup,
            serializer_class=s.ElvantoGroupSerializer,
            permission_classes=(IsAuthenticated, CanSeeGroups, CanImport)
        ),
        name='elvanto_group'
    ),
    # Elvanto group buttons
    url(
        r'^v1/elvanto/group_fetch/$',
        v.ElvantoFetchButton.as_view(),
        name='fetch_elvanto_groups'
    ),
    url(
        r'^v1/elvanto/group_pull/$',
        v.ElvantoPullButton.as_view(),
        name='pull_elvanto_groups'
    ),
    # keyword views
    url(
        r'^v1/keywords/$',
        v.ApiCollection.as_view(
            model_class=Keyword,
            serializer_class=s.KeywordSerializer,
            filter_list=True,
            filters={'is_archived': False},
            permission_classes=(IsAuthenticated, CanSeeKeywords)
        ),
        name='keywords'
    ),
    url(
        r'^v1/keywords_archive/$',
        v.ApiCollection.as_view(
            model_class=Keyword,
            serializer_class=s.KeywordSerializer,
            filter_list=True,
            filters={'is_archived': True},
            permission_classes=(IsAuthenticated, IsStaff)
        ),
        name='keywords_archive'
    ),
    url(
        r'^v1/keywords/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=Keyword,
            serializer_class=s.KeywordSerializer,
            permission_classes=(IsAuthenticated, CanSeeKeyword)
        ),
        name='keyword'
    ),
    # queued messages views
    url(
        r'^v1/queued/sms/$',
        v.ApiCollection.as_view(
            model_class=QueuedSms,
            serializer_class=s.QueuedSmsSerializer,
            filter_list=True,
            filters={'sent': False},
            permission_classes=(IsAuthenticated, IsStaff)
        ),
        name='queued_smss'
    ),
    url(
        r'^v1/queued/sms/(?P<pk>[0-9]+)$',
        v.ApiMember.as_view(
            model_class=QueuedSms,
            serializer_class=s.QueuedSmsSerializer,
            permission_classes=(IsAuthenticated, IsStaff)
        ),
        name='queued_sms'
    ),
]
