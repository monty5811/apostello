# -*- coding: utf-8 -*-
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.cache import cache
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, SmsInbound
from apostello.tasks import fetch_elvanto_groups, pull_elvanto_groups

from .serializers import SmsInboundSerializer


class ApiCollection(APIView):
    """Basic collection view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated,)
    model_class = None
    serializer_class = None
    filter_list = False
    filters = {}

    def get(self, request, format=None):
        objs = self.model_class.objects.all()
        if self.filter_list:
            objs = objs.filter(**self.filters)
        serializer = self.serializer_class(objs, many=True)
        return Response(serializer.data)


class ApiMember(APIView):
    """Basic member view. Check user is authenticated by default."""
    permission_classes = (IsAuthenticated,)
    model_class = None
    serializer_class = None

    def get(self, request, format=None, **kwargs):
        obj = get_object_or_404(self.model_class, pk=kwargs['pk'])

        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        """Handles all the toggle buttons."""
        pk = kwargs['pk']
        reingest_sms = True if request.data.get('reingest', False) == 'true' else False
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


class ApiCollectionRecentSms(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, format=None, **kwargs):
        objs = SmsInbound.objects.filter(sender_num=Recipient.objects.get(pk=kwargs['pk']).number)
        serializer = SmsInboundSerializer(objs, many=True)
        return Response(serializer.data)


class ApiCollectionKeywordSms(APIView):
    permission_classes = (IsAuthenticated,)
    archive = False

    def get(self, request, format=None, **kwargs):
        keyword_obj = Keyword.objects.get(pk=kwargs['pk'])
        self.check_object_permissions(request, keyword_obj)
        objs = SmsInbound.objects.filter(
            matched_keyword=str(keyword_obj)
        )
        if self.archive:
            objs = objs.filter(is_archived=True)
        else:
            objs = objs.filter(is_archived=False)
        serializer = SmsInboundSerializer(objs, many=True)
        return Response(serializer.data)


class ApiCollectionKeywordWall(APIView):
    permission_classes = (IsAuthenticated,)
    only_live = False

    def get(self, request, format=None, **kwargs):
        keyword_obj = Keyword.objects.get(pk=kwargs['pk'])
        self.check_object_permissions(request, keyword_obj)
        # check cache
        if self.only_live:
            objs = cache.get('keyword_{}_only_live'.format(kwargs['pk']))
            if objs is None:
                objs = SmsInbound.objects.filter(
                    matched_keyword=str(keyword_obj)
                )
                objs = objs.filter(is_archived=False)
                objs = objs.filter(display_on_wall=True)
                cache.set('keyword_{}_only_live'.format(kwargs['pk']), objs, 120)
        else:
            objs = cache.get('keyword_{}_all'.format(kwargs['pk']))
            if objs is None:
                objs = SmsInbound.objects.filter(
                    matched_keyword=str(keyword_obj)
                )
                objs = objs.filter(is_archived=False)
                cache.set('keyword_{}_all'.format(kwargs['pk']), objs, 120)

        serializer = SmsInboundSerializer(objs, many=True)
        return Response(serializer.data)


class ApiCollectionAllWall(APIView):
    permission_classes = (IsAuthenticated,)
    only_live = False

    def get(self, request, format=None, **kwargs):
        # check cache
        if self.only_live:
            objs = cache.get('wall_only_live')
            if objs is None:
                objs = SmsInbound.objects.filter(is_archived=False).filter(display_on_wall=True)
                cache.set('wall_only_live', objs, 120)
        else:
            objs = cache.get('wall_all')
            if objs is None:
                objs = SmsInbound.objects.filter(is_archived=False)
                cache.set('wall_all', objs, 120)

        serializer = SmsInboundSerializer(objs, many=True)
        return Response(serializer.data)


class ElvantoPullButton(LoginRequiredMixin, ProfilePermsMixin, View):
    required_perms = ['can_see_groups']

    def post(self, request, format=None, **kwargs):
        pull_elvanto_groups.delay(force=True)
        return JsonResponse({'status': 'pulling'})


class ElvantoFetchButton(LoginRequiredMixin, ProfilePermsMixin, View):
    required_perms = ['can_see_groups']

    def post(self, request, format=None, **kwargs):
        fetch_elvanto_groups.delay(force=True)
        return JsonResponse({'status': 'fetching'})
