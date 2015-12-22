# -*- coding: utf-8 -*-

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from solo.admin import SingletonModelAdmin

from apostello import models

admin.site.register(models.SiteConfiguration, SingletonModelAdmin)
admin.site.register(models.DefaultResponses, SingletonModelAdmin)


@admin.register(models.SmsOutbound)
class SmsOutboundAdmin(admin.ModelAdmin):
    list_display = (
        'content',
        'recipient',
        'time_sent',
        'sent_by',
        'sid',
    )


@admin.register(models.SmsInbound)
class SmsInboundAdmin(admin.ModelAdmin):
    list_display = (
        'content',
        'sender_name',
        'matched_keyword',
        'time_received',
        'sid',
    )


@admin.register(models.Keyword)
class KeywordAdmin(admin.ModelAdmin):
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
    list_display = (
        'full_name',
        'number',
        'is_blocking',
        'is_archived',
    )


@admin.register(models.RecipientGroup)
class RecipientGroupAdmin(admin.ModelAdmin):
    list_display = (
        'name',
        'description',
        'is_archived',
    )


@admin.register(models.ElvantoGroup)
class ElvantoGroupAdmin(admin.ModelAdmin):
    list_display = (
        'name',
        'sync',
        'e_id',
        'last_synced',
    )

admin.site.unregister(User)


class UserProfileInline(admin.StackedInline):
    model = models.UserProfile


class UserProfileAdmin(UserAdmin):
    inlines = [UserProfileInline, ]

admin.site.register(User, UserProfileAdmin)
