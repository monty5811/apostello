from django.contrib.auth.models import User
from django.contrib.humanize.templatetags.humanize import naturaltime
from rest_framework import serializers
from drf_queryfields import QueryFieldsMixin

from apostello.models import (Keyword, QueuedSms, Recipient, RecipientGroup, SmsInbound, SmsOutbound, UserProfile)
from elvanto.models import ElvantoGroup
from site_config.models import SiteConfiguration


class BaseModelSerializer(QueryFieldsMixin, serializers.ModelSerializer):
    pass


class ElvantoGroupSerializer(BaseModelSerializer):
    """Serialize apostello.models.ElvantoGroup."""
    last_synced = serializers.DateTimeField()

    class Meta:
        model = ElvantoGroup
        fields = ('name', 'pk', 'sync', 'last_synced', )


class KeywordSerializer(BaseModelSerializer):
    """Serialize apostello.models.Keyword for use in table."""
    url = serializers.CharField(source='get_absolute_url')
    responses_url = serializers.CharField(source='get_responses_url')
    num_replies = serializers.CharField(source='num_matches')
    num_archived_replies = serializers.CharField(source='num_archived_matches')
    is_live = serializers.BooleanField()

    class Meta:
        model = Keyword
        fields = (
            'keyword', 'pk', 'description', 'current_response', 'is_live', 'url', 'responses_url', 'num_replies',
            'num_archived_replies', 'is_archived', 'disable_all_replies', 'custom_response', 'deactivated_response',
            'too_early_response', 'activate_time', 'deactivate_time', 'linked_groups', 'owners', 'subscribed_to_digest',
        )


class SmsInboundSerializer(BaseModelSerializer):
    """Serialize apostello.models.SmsInbound for use in logs and wall."""
    time_received = serializers.DateTimeField()

    class Meta:
        model = SmsInbound
        fields = (
            'sid', 'pk', 'sender_name', 'content', 'time_received', 'dealt_with', 'is_archived', 'display_on_wall',
            'matched_keyword', 'matched_colour', 'sender_pk',
        )


class RecipientSerializer(BaseModelSerializer):
    """Serialize apostello.models.Recipient for use in table."""
    number = serializers.SerializerMethodField()

    def get_number(self, obj):
        user = self.context['request'].user
        if user.userprofile.can_see_contact_nums or user.is_staff:
            return str(obj.number)

        return ''

    class Meta:
        model = Recipient
        fields = (
            'first_name', 'last_name', 'number', 'pk', 'full_name', 'is_archived', 'is_blocking', 'do_not_reply',
            'last_sms',
        )


class RecipientSimpleSerializer(BaseModelSerializer):
    class Meta:
        model = Recipient
        fields = ('full_name', 'pk', )


class SmsOutboundSerializer(BaseModelSerializer):
    """Serialize apostello.models.SmsOutbound for use in log."""
    time_sent = serializers.DateTimeField()
    recipient = RecipientSimpleSerializer()

    class Meta:
        model = SmsOutbound
        fields = ('content', 'pk', 'time_sent', 'sent_by', 'recipient', )


class RecipientGroupSerializer(BaseModelSerializer):
    """Serialize apostello.models.RecipientGroup for use in edit page."""
    cost = serializers.FloatField(source='calculate_cost')
    url = serializers.CharField(source='get_absolute_url')
    members = RecipientSimpleSerializer(many=True, read_only=True, source='recipient_set')
    nonmembers = RecipientSimpleSerializer(many=True, read_only=True, source='all_recipients_not_in_group')

    class Meta:
        model = RecipientGroup
        fields = ('name', 'pk', 'description', 'members', 'nonmembers', 'cost', 'url', 'is_archived', )


class UserSerializer(BaseModelSerializer):
    """Serialize user model."""
    is_social = serializers.SerializerMethodField()

    def get_is_social(self, obj):
        return obj.socialaccount_set.count() > 0

    class Meta:
        model = User
        fields = ('pk', 'email', 'username', 'is_staff', 'is_social', )


class UserProfileSerializer(BaseModelSerializer):
    """Serialize apostello.models.UserProfile for use in table."""
    user = UserSerializer(read_only=True)

    class Meta:
        model = UserProfile
        fields = (
            'pk', 'user', 'approved', 'can_see_groups', 'can_see_contact_names', 'can_see_keywords', 'can_see_outgoing',
            'can_see_incoming', 'can_send_sms', 'can_see_contact_nums', 'can_import', 'can_archive',
        )


class QueuedSmsSerializer(BaseModelSerializer):
    """Serialize queued messages"""
    time_to_send_formatted = serializers.SerializerMethodField()
    recipient = serializers.SerializerMethodField()
    recipient_group = RecipientGroupSerializer(read_only=True)

    def get_time_to_send_formatted(self, obj):
        """Next run time in humand friendly format."""
        return naturaltime(obj.time_to_send)

    def get_recipient(self, obj):
        recip = RecipientSerializer(instance=obj.recipient, read_only=True, context=self.context)
        return recip.data

    class Meta:
        model = QueuedSms
        fields = (
            'pk', 'time_to_send', 'time_to_send_formatted', 'sent', 'failed', 'content', 'recipient', 'recipient_group',
            'sent_by',
        )


class SiteConfigurationSerializer(BaseModelSerializer):
    auto_add_new_groups = RecipientGroupSerializer(many=True, read_only=True)

    class Meta:
        model = SiteConfiguration
        fields = (
            'site_name', 'sms_char_limit', 'default_number_prefix', 'disable_all_replies', 'disable_email_login_form',
            'office_email', 'auto_add_new_groups', 'slack_url', 'sync_elvanto', 'not_approved_msg', 'email_host',
            'email_port', 'email_username', 'email_password', 'email_from',
        )
