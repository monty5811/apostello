# -*- coding: utf-8 -*-

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from solo.admin import SingletonModelAdmin

from apostello import models

admin.site.register(models.RecipientGroup)
admin.site.register(models.Recipient)
admin.site.register(models.Keyword)
admin.site.register(models.SmsInbound)
admin.site.register(models.SmsOutbound)
admin.site.register(models.SiteConfiguration, SingletonModelAdmin)
admin.site.register(models.DefaultResponses, SingletonModelAdmin)
admin.site.unregister(User)


class UserProfileInline(admin.StackedInline):
    model = models.UserProfile


class UserProfileAdmin(UserAdmin):
    inlines = [UserProfileInline, ]

admin.site.register(User, UserProfileAdmin)
