from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User

from apostello import models


@admin.register(models.SmsOutbound)
class SmsOutboundAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.SmsOutbound."""
    list_display = (
        'content',
        'recipient',
        'time_sent',
        'sent_by',
        'sid',
    )


@admin.register(models.SmsInbound)
class SmsInboundAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.SmsInbound."""
    list_display = (
        'content',
        'sender_name',
        'matched_keyword',
        'time_received',
        'sid',
    )


@admin.register(models.Keyword)
class KeywordAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.Keyword."""
    list_display = (
        'keyword',
        'is_live',
        'activate_time',
        'deactivate_time',
        'description',
        'custom_response',
        'deactivated_response',
        'too_early_response',
        'is_archived',
    )


@admin.register(models.Recipient)
class RecipientAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.Recipient."""
    list_display = (
        'full_name',
        'number',
        'is_blocking',
        'is_archived',
        'do_not_reply',
    )


@admin.register(models.RecipientGroup)
class RecipientGroupAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.RecipientGroup."""
    list_display = (
        'name',
        'description',
        'is_archived',
    )


admin.site.unregister(User)


class UserProfileInline(admin.StackedInline):
    """Inline for apostello.models.UserProfile."""
    model = models.UserProfile


class UserProfileAdmin(UserAdmin):
    """Admin class for apostello.models.UserProfile."""
    inlines = [UserProfileInline, ]


admin.site.register(User, UserProfileAdmin)
