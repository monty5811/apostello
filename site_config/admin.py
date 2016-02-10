from django.contrib import admin
from solo.admin import SingletonModelAdmin

from . import models

admin.site.register(models.SiteConfiguration, SingletonModelAdmin)
admin.site.register(models.DefaultResponses, SingletonModelAdmin)
