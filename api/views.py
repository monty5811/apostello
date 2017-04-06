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

from api.drf_permissions import CanSeeKeywords, CanSendSms
from api.serializers import SmsInboundSerializer
from apostello.forms import SendAdhocRecipientsForm, SendRecipientGroupForm
from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, SmsInbound, SmsOutbound


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
    pagination_class = StandardPagination

    def get_queryset(self):
        return self._get_queryset()

    def _get_queryset(self):
        """Handle get requests."""
        objs = self.model_class.objects.all()
        if self.related_field is not None:
            objs = objs.select_related(self.related_field)
        if self.prefetch_fields is not None:
            objs = objs.prefetch_related(*self.prefetch_fields)
        if not self.request.user.is_staff  \
                and self.model_class is not SmsInbound \
                and self.model_class is not SmsOutbound:
            # filter out archived items
            objs = objs.filter(is_archived=False)
        return objs


class ApiSmsCollection(ApiCollection):
    def get_queryset(self):
        qs = self._get_queryset()
        if self.request.user.is_staff:
            return qs

        blocked_keywords = [
            x.keyword for x in Keyword.objects.all()
            if not x.can_user_access(self.request.user)
        ]
        return qs.exclude(matched_keyword__in=blocked_keywords)


class QueuedSmsCollection(ApiCollection):
    def get_queryset(self):
        """Return only messages that have not been sent"""
        return self.model_class.objects.all().filter(sent=False)


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

    def get_obj(self, kwargs):
        try:
            obj = get_object_or_404(self.model_class, pk=kwargs['pk'])
        except KeyError:
            obj = get_object_or_404(
                self.model_class, keyword=kwargs['keyword']
            )

        return obj

    def get(self, request, format=None, **kwargs):
        """Handle get requests."""
        obj = self.get_obj(kwargs)

        serializer = self.serializer_class(obj, context={'request': request})
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        """Handle toggle buttons."""
        obj = self.get_obj(kwargs)

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


class ArchiveAllResponses(APIView):
    """Archive all matched responses"""
    permission_classes = (IsAuthenticated, CanSeeKeywords)

    def post(self, request, format=None, **kwargs):
        keyword = get_object_or_404(Keyword, keyword=kwargs['keyword'])

        if not keyword.can_user_access(request.user):
            return Response({}, status=status.HTTP_403_FORBIDDEN)

        if request.data.get('tick_to_archive_all_responses'):
            for sms in keyword.fetch_matches():
                sms.archive()

        return Response({}, status=status.HTTP_200_OK)


class ApiSendAdhoc(APIView):
    """Send SMS to individuals."""
    permission_classes = (IsAuthenticated, CanSendSms)

    def post(self, request, format=None, **kwargs):
        form = SendAdhocRecipientsForm(request.data, user=request.user)
        if form.is_valid():
            for recipient in form.cleaned_data['recipients']:
                # send and save message
                recipient.send_message(
                    content=form.cleaned_data['content'],
                    eta=form.cleaned_data['scheduled_time'],
                    sent_by=str(self.request.user)
                )

            if form.cleaned_data['scheduled_time'] is None:
                msg = {
                    'type_':
                    'info',
                    'text':
                    "Sending \"{0}\"...\n"
                    "Please check the logs for verification...".
                    format(form.cleaned_data['content'])
                }
            else:
                msg = {
                    'type_':
                    'info',
                    'text':
                    "'{0}' has been successfully queued.".
                    format(form.cleaned_data['content'])
                }
            return Response(
                {
                    'messages': [msg],
                    'errors': {}
                },
                status=status.HTTP_201_CREATED
            )

        return Response(
            {
                'messages': [],
                'errors': form.errors
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class ApiSendGroup(APIView):
    """Send SMS to group."""
    permission_classes = (IsAuthenticated, CanSendSms)

    def post(self, request, format=None, **kwargs):
        form = SendRecipientGroupForm(request.data, user=request.user)
        if form.is_valid():
            form.cleaned_data['recipient_group'].send_message(
                content=form.cleaned_data['content'],
                eta=form.cleaned_data['scheduled_time'],
                sent_by=str(self.request.user)
            )
            if form.cleaned_data['scheduled_time'] is None:
                msg = {
                    'type_':
                    'info',
                    'text':
                    "Sending '{0}' to '{1}'...\n"
                    "Please check the logs for verification...".format(
                        form.cleaned_data['content'],
                        form.cleaned_data['recipient_group']
                    )
                }
            else:
                msg = {
                    'type_':
                    'info',
                    'text':
                    "'{0}' has been successfully queued.".
                    format(form.cleaned_data['content']),
                }

            return Response(
                {
                    'messages': [msg],
                    'errors': {}
                },
                status=status.HTTP_201_CREATED
            )

        return Response(
            {
                'messages': [],
                'errors': form.errors
            },
            status=status.HTTP_400_BAD_REQUEST
        )
