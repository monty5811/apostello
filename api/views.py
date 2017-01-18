import json

from django.core.cache import cache
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View
from django_q.tasks import async
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework import status
from rest_framework.pagination import PageNumberPagination

from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, SmsInbound

from .serializers import SmsInboundSerializer, SmsInboundSimpleSerializer


class StandardPagination(PageNumberPagination):
    """Base class for common pagination."""
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 1000


class ApiCollection(generics.ListAPIView):
    """Basic collection view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated, )
    model_class = None
    serializer_class = None
    related_field = None
    prefetch_fields = None
    filter_list = False
    filters = {}
    pagination_class = StandardPagination

    def get_queryset(self):
        """Handle get requests."""
        objs = self.model_class.objects.all()
        if self.related_field is not None:
            objs = objs.select_related(self.related_field)
        if self.prefetch_fields is not None:
            objs = objs.prefetch_related(*self.prefetch_fields)
        if self.filter_list:
            objs = objs.filter(**self.filters)
        return objs

    def get_serializer_context(self):
        context = super(ApiCollection, self).get_serializer_context()
        context['request'] = self.request
        return context


class ApiCollectionRecentSms(ApiCollection):
    """SMS collection for a single recipient."""
    serializer_class = SmsInboundSerializer

    def get_queryset(self):
        """Handle get requests."""
        objs = SmsInbound.objects.filter(
            sender_num=Recipient.objects.get(pk=self.kwargs['pk']).number
        )
        return objs


class ApiCollectionKeywordSms(ApiCollection):
    """SMS collection for a single keyword."""
    serializer_class = SmsInboundSerializer
    pk = None
    archive = False

    def get_queryset(self):
        """Handle get requests."""
        keyword_obj = Keyword.objects.get(pk=self.kwargs['pk'])
        self.check_object_permissions(self.request, keyword_obj)
        objs = SmsInbound.objects.filter(matched_keyword=str(keyword_obj))
        if self.archive:
            objs = objs.filter(is_archived=True)
        else:
            objs = objs.filter(is_archived=False)
        return objs


class ApiCollectionAllWall(ApiCollection):
    """SMS collection for the curating wall."""
    serializer_class = SmsInboundSimpleSerializer

    def get_queryset(self):
        """Handle get requests."""
        cache_key = 'live_wall_all'
        objs = cache.get(cache_key)
        if objs is None:
            objs = SmsInbound.objects.filter(is_archived=False)
            cache.set(cache_key, objs, 120)
        return objs


class ApiMember(APIView):
    """Basic member view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated, )
    model_class = None
    serializer_class = None

    @staticmethod
    def simple_update(request, obj, attr_name):
        """Switch the value of a supplied field.

        e.g. toggles the dealt with status of a keyword
        """
        attr_val = request.data.get(attr_name)
        if attr_val is not None:
            setattr(obj, attr_name, not attr_val)
        obj.save()
        return obj

    def get(self, request, format=None, **kwargs):
        """Handle get requests."""
        obj = get_object_or_404(self.model_class, pk=kwargs['pk'])
        serializer = self.serializer_class(obj, context={'request': request})
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        """Handle toggle buttons."""
        pk = kwargs['pk']
        obj = get_object_or_404(self.model_class, pk=pk)

        obj = self.simple_update(request, obj, 'dealt_with')
        obj = self.simple_update(request, obj, 'display_on_wall')
        obj = self.simple_update(request, obj, 'sync')

        archived = request.data.get('archived')
        if archived is not None:
            if archived:
                obj.is_archived = False
                obj.save()
            else:
                # restrict permission:
                if request.user.profile.can_archive:
                    obj.archive()
                else:
                    return Response({}, status=status.HTTP_403_FORBIDDEN)

        if request.data.get('reingest'):
            obj = obj.reimport()

        user_profile = request.data.get('user_profile')
        if user_profile is not None:
            user_profile.pop('user')
            user_profile.pop('pk')
            for x in user_profile:
                setattr(obj, x, user_profile[x])
            obj.save()

        is_member = request.data.get('member')
        if is_member is not None:
            contact = Recipient.objects.get(pk=request.data.get('contactPk'))
            if is_member:
                obj.recipient_set.remove(contact)
            else:
                obj.recipient_set.add(contact)

            obj.save()

        cancel_queued_sms = request.data.get('cancel_sms')
        if cancel_queued_sms is not None:
            r = Response({'pk': obj.pk}, status=status.HTTP_200_OK)
            obj.cancel()
            return r

        serializer = self.serializer_class(obj, context={'request': request})
        return Response(serializer.data)


class ElvantoPullButton(ProfilePermsMixin, View):
    """View for elvanto pull button."""
    required_perms = ['can_import']

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        async('apostello.tasks.pull_elvanto_groups', force=True)
        return JsonResponse({'status': 'pulling'})


class ElvantoFetchButton(ProfilePermsMixin, View):
    """View for elvanto fetch button."""
    required_perms = ['can_import']

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        async('apostello.tasks.fetch_elvanto_groups', force=True)
        return JsonResponse({'status': 'fetching'})
