# -*- coding: utf-8 -*-
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.cache import cache
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.pagination import PageNumberPagination

from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, SmsInbound
from apostello.tasks import fetch_elvanto_groups, pull_elvanto_groups

from .serializers import SmsInboundSerializer, SmsInboundSimpleSerializer


class StandardPagination(PageNumberPagination):
    page_size = 100
    page_size_query_param = 'page_size'
    max_page_size = 1000


class ApiCollection(generics.ListAPIView):
    """Basic collection view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated, )
    model_class = None
    serializer_class = None
    related_field = None
    filter_list = False
    filters = {}
    pagination_class = StandardPagination

    def get_queryset(self):
        """Handle get requests."""
        if self.related_field is None:
            objs = self.model_class.objects.all()
        else:
            objs = self.model_class.objects.all().select_related(
                self.related_field
            )
        if self.filter_list:
            objs = objs.filter(**self.filters)
        return objs


class ApiMember(APIView):
    """Basic member view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated, )
    model_class = None
    serializer_class = None

    def get(self, request, format=None, **kwargs):
        """Handle get requests."""
        obj = get_object_or_404(self.model_class, pk=kwargs['pk'])
        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        """Handle toggle buttons."""
        pk = kwargs['pk']
        reingest_sms = True if request.data.get(
            'reingest', False
        ) == 'true' else False
        deal_with_sms = request.data.get('deal_with')
        archive = request.data.get('archive')
        display_on_wall = request.data.get('display_on_wall')
        e_sync = request.data.get('sync')

        obj = get_object_or_404(self.model_class, pk=pk)
        if archive is not None:
            if archive == 'true':
                obj.archive()
            else:
                obj.is_archived = False
        if reingest_sms:
            obj.reimport()
        if deal_with_sms is not None:
            if deal_with_sms == 'true':
                obj.dealt_with = True
            else:
                obj.dealt_with = False
        if display_on_wall is not None:
            if display_on_wall == 'true':
                obj.display_on_wall = True
            else:
                obj.display_on_wall = False
        if e_sync is not None:
            if e_sync == 'true':
                obj.sync = False
            else:
                obj.sync = True

        obj.save()
        serializer = self.serializer_class(obj)
        return Response(serializer.data)


class ApiCollectionRecentSms(generics.ListAPIView):
    """SMS collection for a single recipient."""
    permission_classes = (IsAuthenticated, )
    pagination_class = StandardPagination
    serializer_class = SmsInboundSerializer

    def get_queryset(self):
        """Handle get requests."""
        objs = SmsInbound.objects.filter(
            sender_num=Recipient.objects.get(pk=self.kwargs['pk']).number
        )
        return objs


class ApiCollectionKeywordSms(generics.ListAPIView):
    """SMS collection for a single keyword."""
    permission_classes = (IsAuthenticated, )
    pagination_class = StandardPagination
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


class ApiCollectionAllWall(generics.ListAPIView):
    """SMS collection for the curating wall."""
    permission_classes = (IsAuthenticated, )
    pagination_class = StandardPagination
    serializer_class = SmsInboundSimpleSerializer

    def get_queryset(self):
        """Handle get requests."""
        cache_key = 'live_wall_all'
        objs = cache.get(cache_key)
        if objs is None:
            objs = SmsInbound.objects.filter(is_archived=False)
            cache.set(cache_key, objs, 120)

        return objs


class ElvantoPullButton(LoginRequiredMixin, ProfilePermsMixin, View):
    """View for elvanto pull button."""
    required_perms = ['can_see_groups']

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        pull_elvanto_groups.delay(force=True)
        return JsonResponse({'status': 'pulling'})


class ElvantoFetchButton(LoginRequiredMixin, ProfilePermsMixin, View):
    """View for elvanto fetch button."""
    required_perms = ['can_see_groups']

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        fetch_elvanto_groups.delay(force=True)
        return JsonResponse({'status': 'fetching'})
