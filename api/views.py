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
            objs = self.model_class.objects.all(
            ).select_related(self.related_field)
        if self.filter_list:
            objs = objs.filter(**self.filters)
        return objs


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
    def get_val(request, val_name):
        """Pull `val_name` from the request data and convert to a boolean or None."""
        val = request.data.get(val_name)
        if val is None:
            return val
        val = True if val == 'true' else False
        return val

    @staticmethod
    def simple_update(request, obj, attr_name):
        """Switch the value of a supplied field.

        e.g. toggles the dealt with status of a keyword
        """
        attr_val = ApiMember.get_val(request, attr_name)
        if attr_val is not None:
            if attr_val:
                setattr(obj, attr_name, False)
            else:
                setattr(obj, attr_name, True)
        obj.save()
        return obj

    def get(self, request, format=None, **kwargs):
        """Handle get requests."""
        obj = get_object_or_404(self.model_class, pk=kwargs['pk'])
        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        """Handle toggle buttons."""
        pk = kwargs['pk']
        obj = get_object_or_404(self.model_class, pk=pk)

        obj = self.simple_update(request, obj, 'dealt_with')
        obj = self.simple_update(request, obj, 'display_on_wall')
        obj = self.simple_update(request, obj, 'sync')

        archived = self.get_val(request, 'archived')
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

        reingest_sms = self.get_val(request, 'reingest')
        if reingest_sms:
            obj.reimport()

        user_profile = request.data.get('user_profile')
        if user_profile is not None:
            user_profile = json.loads(user_profile)
            user_profile.pop('user')
            user_profile.pop('pk')
            for x in user_profile:
                setattr(obj, x, user_profile[x])
            obj.save()

        cancel_task = request.data.get('cancel_task')
        if cancel_task is not None:
            r = Response({'pk': obj.pk}, status=status.HTTP_200_OK)
            obj.delete()
            return r

        serializer = self.serializer_class(obj)
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
