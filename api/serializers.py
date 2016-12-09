import ast

from django.contrib.auth.models import User
from django.contrib.humanize.templatetags.humanize import naturaltime
from rest_framework import serializers

from apostello.models import (
    Keyword, QueuedSms, Recipient, RecipientGroup, SmsInbound, SmsOutbound,
    UserProfile
)
from elvanto.models import ElvantoGroup


class ElvantoGroupSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.ElvantoGroup."""
    last_synced = serializers.DateTimeField(format='%d %b %H:%M')

    class Meta:
        model = ElvantoGroup
        fields = (
            'name',
            'pk',
            'sync',
            'last_synced',
        )


class KeywordSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.Keyword for use in table."""
    url = serializers.CharField(source='get_absolute_url')
    responses_url = serializers.CharField(source='get_responses_url')
    num_replies = serializers.CharField(source='num_matches')
    num_archived_replies = serializers.CharField(source='num_archived_matches')
    is_live = serializers.BooleanField()

    class Meta:
        model = Keyword
        fields = (
            'keyword',
            'pk',
            'description',
            'current_response',
            'is_live',
            'url',
            'responses_url',
            'num_replies',
            'num_archived_replies',
            'is_archived',
        )


class SmsInboundSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.SmsInbound for use in logs and wall."""
    time_received = serializers.DateTimeField(format='%d %b %H:%M')

    class Meta:
        model = SmsInbound
        fields = (
            'sid',
            'pk',
            'sender_name',
            'content',
            'time_received',
            'dealt_with',
            'is_archived',
            'display_on_wall',
            'matched_keyword',
            'matched_colour',
            'matched_link',
            'sender_url',
            'sender_pk',
        )


class SmsInboundSimpleSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.SmsInbound for use in log and wall."""
    time_received = serializers.DateTimeField(format='%d %b %H:%M')

    class Meta:
        model = SmsInbound
        fields = (
            'pk',
            'content',
            'time_received',
            'is_archived',
            'display_on_wall',
            'matched_keyword',
        )


class SmsOutboundSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.SmsOutbound for use in log."""
    time_sent = serializers.DateTimeField(format='%d %b %H:%M')
    recipient = serializers.StringRelatedField()

    class Meta:
        model = SmsOutbound
        fields = (
            'content',
            'pk',
            'time_sent',
            'sent_by',
            'recipient',
            'recipient_url',
        )


class RecipientSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.Recipient for use in table."""
    url = serializers.CharField(source='get_absolute_url')
    number = serializers.SerializerMethodField()

    def get_number(self, obj):
        user = self.context['request'].user
        if user.userprofile.can_see_contact_nums or user.is_staff:
            return str(obj.number)

        return ''

    class Meta:
        model = Recipient
        fields = (
            'first_name',
            'last_name',
            'pk',
            'url',
            'full_name',
            'number',
            'is_archived',
            'is_blocking',
            'do_not_reply',
            'last_sms',
        )


class RecipientSimpleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Recipient
        fields = (
            'full_name',
            'pk',
        )


class RecipientGroupSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.RecipientGroup for use in edit page."""
    cost = serializers.CharField(source='calculate_cost')
    url = serializers.CharField(source='get_absolute_url')
    members = RecipientSimpleSerializer(
        many=True, read_only=True, source='recipient_set'
    )
    nonmembers = RecipientSimpleSerializer(
        many=True, read_only=True, source='all_recipients_not_in_group'
    )

    class Meta:
        model = RecipientGroup
        fields = (
            'name',
            'pk',
            'description',
            'members',
            'nonmembers',
            'cost',
            'url',
            'is_archived',
        )


class UserSerializer(serializers.ModelSerializer):
    """Serialize user model."""

    class Meta:
        model = User
        fields = (
            'email',
            'username',
        )


class UserProfileSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.UserProfile for use in table."""
    user = UserSerializer(read_only=True)
    url = serializers.CharField(source='get_absolute_url')

    class Meta:
        model = UserProfile
        fields = (
            'pk',
            'user',
            'url',
            'approved',
            'can_see_groups',
            'can_see_contact_names',
            'can_see_keywords',
            'can_see_outgoing',
            'can_see_incoming',
            'can_send_sms',
            'can_see_contact_nums',
            'can_import',
            'can_archive',
        )


class QueuedSmsSerializer(serializers.ModelSerializer):
    """Serialize queued messages"""
    time_to_send_formatted = serializers.SerializerMethodField()
    recipient = RecipientSerializer(read_only=True)
    recipient_group = RecipientGroupSerializer(read_only=True)

    def get_time_to_send_formatted(self, obj):
        """Next run time in humand friendly format."""
        return naturaltime(obj.time_to_send)

    class Meta:
        model = QueuedSms
        fields = (
            'pk',
            'time_to_send',
            'time_to_send_formatted',
            'sent',
            'failed',
            'content',
            'recipient',
            'recipient_group',
            'sent_by',
        )
