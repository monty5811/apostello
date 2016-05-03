# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.models import Recipient
from apostello.tasks import update_msgs_name


class Command(BaseCommand):
    """Updates names on messages for all existing contacts."""
    args = ''
    help = 'Update from_name fields'

    def handle(self, *args, **options):
        """Handle the command."""
        for c in Recipient.objects.all():
            update_msgs_name(c.id)
