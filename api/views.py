# -*- coding: utf-8 -*-
from django.core.cache import cache
from django.shortcuts import get_object_or_404
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apostello.models import Keyword, Recipient, SmsInbound

from .serializers import SmsInboundSerializer


class ApiCollection(APIView):
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
    permission_classes = (IsAuthenticated,)
    model_class = None
    serializer_class = None

    def get(self, request, format=None, **kwargs):
        obj = get_object_or_404(self.model_class, pk=kwargs['pk'])

        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        pk = kwargs['pk']
        reingest_sms = True if request.data.get('reingest', False) == 'true' else False
        deal_with_sms = request.data.get('deal_with', None)
        archive = request.data.get('archive', None)
        display_on_wall = request.data.get('display_on_wall', None)

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
        objs = SmsInbound.objects.filter(matched_keyword=str(Keyword.objects.get(pk=kwargs['pk'])))
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
        # check cache
        if self.only_live:
            objs = cache.get('keyword_{}_only_live'.format(kwargs['pk']))
            if objs is None:
                objs = SmsInbound.objects.filter(matched_keyword=str(Keyword.objects.get(pk=kwargs['pk'])))
                objs = objs.filter(is_archived=False)
                objs = objs.filter(display_on_wall=True)
                cache.set('keyword_{}_only_live'.format(kwargs['pk']), objs, 120)
        else:
            objs = cache.get('keyword_{}_all'.format(kwargs['pk']))
            if objs is None:
                objs = SmsInbound.objects.filter(matched_keyword=str(Keyword.objects.get(pk=kwargs['pk'])))
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
