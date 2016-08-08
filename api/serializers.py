import ast

from django.contrib.auth.models import User
from rest_framework import serializers
from django_q.models import Schedule

from apostello.models import (
    Keyword, Recipient, RecipientGroup, SmsInbound, SmsOutbound, UserProfile
)
from elvanto.models import ElvantoGroup


class RecipientGroupSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.RecipientGroup for use in table."""
    cost = serializers.CharField(source='calculate_cost')
    url = serializers.CharField(source='get_absolute_url')
    members = serializers.ListField(source='all_recipients_names')

    class Meta:
        model = RecipientGroup
        fields = (
            'name',
            'pk',
            'description',
            'members',
            'cost',
            'url',
            'is_archived',
        )


class ElvantoGroupSerializer(serializers.ModelSerializer):
    """Serialize apostello.models.ElvantoGroup."""
    last_synced = serializers.DateTimeField(format='%d %b %H:%M')

    class Meta:
        model = ElvantoGroup
        fields = ('name',
                  'pk',
                  'sync',
                  'last_synced', )


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


class UserSerializer(serializers.ModelSerializer):
    """Serialize user model."""

    class Meta:
        model = User
        fields = ('email',
                  'username', )


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


class QScheduleSerializer(serializers.ModelSerializer):
    """Serialize scheduled django-q tasks.

    Note - this will only work with scheduled message tasks.
    """

    next_run = serializers.DateTimeField()
    message_body = serializers.SerializerMethodField()
    recipient = serializers.SerializerMethodField()
    recipient_group = serializers.SerializerMethodField()
    queued_by = serializers.SerializerMethodField()

    @staticmethod
    def _split_args(sched_args):
        """Convert the schedule's args value to tuple."""
        return ast.literal_eval(sched_args)

    def get_message_body(self, obj):
        """Fetch the message body arg."""
        if obj.args is None:
            return None
        return self._split_args(obj.args)[1]

    def get_recipient(self, obj):
        """Fetch the recipient arg and serialize."""
        if obj.args is None:
            return None
        pk = self._split_args(obj.args)[0]
        if pk is not None:
            grp = Recipient.objects.get(pk=pk)
            serializer = RecipientSerializer(grp)
            return serializer.data
        else:
            return {'url': '#', 'full_name': 'n/a'}

    def get_recipient_group(self, obj):
        """Fetch the recipient group arg and serialize."""
        if obj.args is None:
            return None
        grp_name = self._split_args(obj.args)[2]
        if grp_name is not None:
            grp = RecipientGroup.objects.get(name=grp_name)
            serializer = RecipientGroupSerializer(grp)
            return serializer.data
        else:
            return {'url': '#', 'name': 'n/a'}

    def get_queued_by(self, obj):
        """Fetch the queued by arg."""
        if obj.args is None:
            return None
        return self._split_args(obj.args)[3]

    class Meta:
        model = Schedule
        fields = (
            'pk',
            'message_body',
            'recipient',
            'recipient_group',
            'queued_by',
            'next_run',
        )
