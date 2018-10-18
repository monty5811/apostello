import csv
import io

from django.conf import settings
from django.core.cache import cache
from django.core.exceptions import ObjectDoesNotExist
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View
from django_q.tasks import async_task
from phonenumber_field.validators import validate_international_phonenumber
from rest_framework import generics, status
from rest_framework.authtoken.models import Token
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from api import serializers
from api.drf_permissions import CanImport, CanSeeKeywords, CanSendSms, IsStaff
from api.forms import handle_form
from apostello.forms import CsvImport, GroupAllCreateForm, SendAdhocRecipientsForm, SendRecipientGroupForm
from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, RecipientGroup, SmsInbound, SmsOutbound
from elvanto.models import ElvantoGroup
from site_config.forms import DefaultResponsesForm, SiteConfigurationForm
from site_config.models import DefaultResponses, SiteConfiguration


class ActionForbidden(Exception):
    pass


class StandardPagination(PageNumberPagination):
    """Base class for common pagination."""

    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 1000


class ConfigView(APIView):
    permission_classes = (IsAuthenticated, IsStaff)
    model_class = SiteConfiguration
    form_class = SiteConfigurationForm
    serializer_class = serializers.SiteConfigurationSerializer

    def get(self, request, format=None, **kwargs):
        obj = self.model_class.get_solo()
        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        return handle_form(self, request)


class ResponsesView(APIView):
    permission_classes = (IsAuthenticated, IsStaff)
    model_class = DefaultResponses
    form_class = DefaultResponsesForm
    serializer_class = serializers.DefaultResponsesSerializer

    def get(self, request, format=None, **kwargs):
        obj = self.model_class.get_solo()
        serializer = self.serializer_class(obj)
        return Response(serializer.data)

    def post(self, request, format=None, **kwargs):
        return handle_form(self, request)


class CSVImport(APIView):
    permission_classes = (IsAuthenticated, CanImport)
    form_class = CsvImport

    def post(self, request, format=None, **kwargs):
        form = self.form_class(request.data)
        if not form.is_valid():
            return Response(
                {"messages": [{"type_": "warning", "text": "That doesn't look right..."}], "errors": {}},
                status=status.HTTP_400_BAD_REQUEST,
            )
        csv_string = "first_name,last_name,number\n" + form.cleaned_data["csv_data"]
        data = [x for x in csv.DictReader(io.StringIO(csv_string))]
        bad_rows = list()
        for row in data:
            try:
                validate_international_phonenumber(row["number"])
                obj = Recipient.objects.get_or_create(number=row["number"])[0]
                obj.first_name = row["first_name"].strip()
                obj.last_name = row["last_name"].strip()
                obj.is_archived = False
                obj.full_clean()
                obj.save()
            except Exception:
                # catch bad rows and display to the user
                bad_rows.append("{first_name},{last_name},{number}".format(**row))

        if bad_rows:
            msg_text = "Uh oh, something went wrong with these imports!\n\n"
            msg_text = msg_text + "\n".join(bad_rows)
            msg_text = msg_text + "\n\nTry inputting these failed items manually to see what went wrong."
            return Response(
                {"messages": [{"type_": "warning", "text": msg_text}], "errors": {}}, status=status.HTTP_400_BAD_REQUEST
            )
        else:
            msg = {"type_": "info", "text": "Importing your data now..."}
            return Response({"messages": [msg], "errors": {}}, status=status.HTTP_200_OK)


class SetupView(APIView):
    permission_classes = (IsAuthenticated, IsStaff)

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        try:
            api_token = request.user.auth_token
        except ObjectDoesNotExist:
            api_token = "No API Token Generated"

        return Response({"token": str(api_token)}, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        """Handle token generation."""
        if request.data.get("regen"):
            token, created = Token.objects.get_or_create(user=request.user)
            if not created:
                # delete token and make a new one
                token.delete()
                token = Token.objects.create(user=request.user)

        if request.data.get("delete"):
            try:
                token = Token.objects.get(user=request.user)
                token.delete()
            except Token.DoesNotExist:
                # no token to delete, just continue
                pass
            token = "No API Token Generated"

        return Response({"token": str(token)}, status=status.HTTP_200_OK)


class Collection(generics.ListAPIView):
    """Basic collection view. Check user is authenticated by default."""

    permission_classes = (IsAuthenticated,)
    model_class = None
    form_class = None
    serializer_class = None
    related_field = None
    prefetch_fields = None
    pagination_class = StandardPagination

    def filter_objs(self, objs):
        identifier = self.kwargs.get("pk")
        if identifier is None:
            identifier = self.kwargs.get("keyword")

        if identifier is None:
            return objs

        try:
            return objs.filter(pk=identifier)
        except ValueError:
            return objs.filter(keyword=identifier)

    def get_queryset(self):
        return self._get_queryset()[0 : settings.MAX_SMS_N]

    def _get_queryset(self):
        """Handle get requests."""
        objs = self.model_class.objects.all()
        if self.related_field is not None:
            objs = objs.select_related(self.related_field)
        if self.prefetch_fields is not None:
            objs = objs.prefetch_related(*self.prefetch_fields)
        if (
            not self.request.user.is_staff
            and self.model_class is not SmsInbound
            and self.model_class is not SmsOutbound
            and self.model_class is not ElvantoGroup
        ):
            # filter out archived items
            objs = objs.filter(is_archived=False)

        return self.filter_objs(objs)

    def post(self, request, format=None, **kwargs):
        return handle_form(self, request)


class RecipientCollection(Collection):
    def post(self, request, format=None, **kwargs):
        return handle_form(self, request, user=request.user)


class UserCollection(Collection):
    def _get_queryset(self):
        return self.model_class.objects.all().order_by("email")


class SmsCollection(Collection):
    def get_queryset(self):
        qs = self._get_queryset()
        if self.request.user.is_staff:
            return qs

        blocked_keywords = [x.keyword for x in Keyword.objects.all() if not x.can_user_access(self.request.user)]
        return qs.exclude(matched_keyword__in=blocked_keywords)[0 : settings.MAX_SMS_N]


class QueuedSmsCollection(Collection):
    def get_queryset(self):
        """Return only messages that have not been sent"""
        return self.model_class.objects.all().filter(sent=False)


class ActionObj(APIView):
    permission_classes = (IsAuthenticated,)
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

    def _action(self, request, obj):
        raise NotImplementedError

    def get_obj(self, kwargs):
        try:
            obj = get_object_or_404(self.model_class, pk=kwargs["pk"])
        except KeyError:
            obj = get_object_or_404(self.model_class, keyword=kwargs["keyword"])

        return obj

    def post(self, request, format=None, **kwargs):
        obj = self.get_obj(kwargs)
        try:
            obj = self._action(request, obj)
        except ActionForbidden:
            return Response({}, status=status.HTTP_403_FORBIDDEN)

        serializer = self.serializer_class(obj, context={"request": request})
        return Response(serializer.data)


class ArchiveObj(ActionObj):
    """Post to this view will archive the relevant object."""

    def _action(self, request, obj):
        """Handle toggle buttons."""
        archived = request.data.get("archived")
        if archived is not None:
            if archived:
                obj.is_archived = False
                obj.save()
            else:
                # restrict permission:
                if request.user.is_staff or request.user.profile.can_archive:
                    obj.archive()
                else:
                    raise ActionForbidden
        return obj


class ReingestObj(ActionObj):
    """Post to this view will call `reingest` on object"""

    def _action(self, request, obj):
        if request.data.get("reingest"):
            obj = obj.reimport()
        return obj


class CancelObj(ActionObj):
    """Post to this view will call `cancel` on object"""

    def _action(self, request, obj):
        cancel_queued_sms = request.data.get("cancel_sms")
        if cancel_queued_sms is not None:
            obj.cancel()
            return obj


class ObjSimpleUpdate(ActionObj):
    field = None

    def _action(self, request, obj):
        obj = self.simple_update(request, obj, self.field)
        return obj


class UpdateUserProfile(ActionObj):
    def _action(self, request, obj):
        user_profile = request.data.get("user_profile")
        if user_profile is not None:
            user_profile.pop("user")
            user_profile.pop("pk")
            for x in user_profile:
                setattr(obj, x, user_profile[x])
            obj.save()
        return obj


class UpdateGroupMembers(ActionObj):
    def _action(self, request, obj):
        is_member = request.data.get("member")
        if is_member is not None:
            contact = Recipient.objects.get(pk=request.data.get("contactPk"))
            if is_member:
                obj.recipient_set.remove(contact)
            else:
                obj.recipient_set.add(contact)

            obj.save()

        return obj


class ElvantoPullButton(ProfilePermsMixin, View):
    """View for elvanto pull button."""

    required_perms = ["can_import"]

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        async_task("apostello.tasks.pull_elvanto_groups", force=True)
        return JsonResponse({"status": "pulling"})


class ElvantoFetchButton(ProfilePermsMixin, View):
    """View for elvanto fetch button."""

    required_perms = ["can_import"]

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        async_task("apostello.tasks.fetch_elvanto_groups", force=True)
        return JsonResponse({"status": "fetching"})


class TwilioDelete(APIView):
    """View for deleting messages from here and Twilio."""

    permission_classes = (IsAuthenticated, IsStaff)

    def post(self, request, format=None, **kwargs):
        """Handle post requests."""
        incoming_pks = request.data.get("incoming_pks")
        outgoing_pks = request.data.get("outgoing_pks")
        for pk in incoming_pks:
            sms = get_object_or_404(SmsInbound, pk=pk)
            sms.delete_from_twilio()

        for pk in outgoing_pks:
            sms = get_object_or_404(SmsOutbound, pk=pk)
            sms.delete_from_twilio()

        return JsonResponse({"status": ""})


class ArchiveAllResponses(APIView):
    """Archive all matched responses"""

    permission_classes = (IsAuthenticated, CanSeeKeywords)

    def post(self, request, format=None, **kwargs):
        keyword = get_object_or_404(Keyword, keyword=kwargs["keyword"])

        if not keyword.can_user_access(request.user):
            return Response({}, status=status.HTTP_403_FORBIDDEN)

        if request.data.get("tick_to_archive_all_responses"):
            for sms in keyword.fetch_matches():
                sms.archive()

        return Response({}, status=status.HTTP_200_OK)


class SendAdhoc(APIView):
    """Send SMS to individuals."""

    permission_classes = (IsAuthenticated, CanSendSms)

    def post(self, request, format=None, **kwargs):
        form = SendAdhocRecipientsForm(request.data, user=request.user)
        if form.is_valid():
            for recipient in form.cleaned_data["recipients"]:
                # send and save message
                recipient.send_message(
                    content=form.cleaned_data["content"],
                    eta=form.cleaned_data["scheduled_time"],
                    sent_by=str(self.request.user),
                )

            if form.cleaned_data["scheduled_time"] is None:
                msg_txt = 'Sending "{0}"...\nPlease check the logs for verification...'.format(
                    form.cleaned_data["content"]
                )
                msg = {"type_": "info", "text": msg_txt}
            else:
                msg = {
                    "type_": "info",
                    "text": "'{0}' has been successfully queued.".format(form.cleaned_data["content"]),
                }
            return Response({"messages": [msg], "errors": {}}, status=status.HTTP_201_CREATED)

        return Response({"messages": [], "errors": form.errors}, status=status.HTTP_400_BAD_REQUEST)


class SendGroup(APIView):
    """Send SMS to group."""

    permission_classes = (IsAuthenticated, CanSendSms)

    def post(self, request, format=None, **kwargs):
        form = SendRecipientGroupForm(request.data, user=request.user)
        if form.is_valid():
            form.cleaned_data["recipient_group"].send_message(
                content=form.cleaned_data["content"],
                eta=form.cleaned_data["scheduled_time"],
                sent_by=str(self.request.user),
            )
            if form.cleaned_data["scheduled_time"] is None:
                msg_txt = "Sending '{0}' to '{1}'...\nPlease check the logs for verification...".format(
                    form.cleaned_data["content"], form.cleaned_data["recipient_group"]
                )
                msg = {"type_": "info", "text": msg_txt}
            else:
                msg = {
                    "type_": "info",
                    "text": "'{0}' has been successfully queued.".format(form.cleaned_data["content"]),
                }

            return Response({"messages": [msg], "errors": {}}, status=status.HTTP_201_CREATED)

        return Response({"messages": [], "errors": form.errors}, status=status.HTTP_400_BAD_REQUEST)


class CreateAllGroup(APIView):
    """View to handle creation of an 'all' group."""

    permission_classes = (IsAuthenticated, IsStaff)

    def post(self, request, format=None, **kwargs):
        """Create the group and add all active users."""
        form = GroupAllCreateForm(request.data)
        if form.is_valid():
            g, created = RecipientGroup.objects.get_or_create(
                name=form.cleaned_data["group_name"], defaults={"description": 'Created using "All" form'}
            )
            if not created:
                g.recipient_set.clear()
            for r in Recipient.objects.filter(is_archived=False):
                g.recipient_set.add(r)
            g.save()

            msg = {"type_": "info", "text": "Group created."}
            return Response({"messages": [msg], "errors": {}}, status=status.HTTP_201_CREATED)

        return Response({"messages": [], "errors": form.errors}, status=status.HTTP_400_BAD_REQUEST)
