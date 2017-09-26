from django.contrib import admin

from . import models


@admin.register(models.ElvantoGroup)
class ElvantoGroupAdmin(admin.ModelAdmin):
    """Admin class for apostello.models.ElvantoGroup."""
    list_display = (
        'name',
        'sync',
        'e_id',
        'last_synced',
    )
