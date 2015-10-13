# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import import_outgoing_sms


class Command(BaseCommand):
    """
    Checks Twilio's outgoing logs for our number and updates the
    database to match.
    """
    args = ''
    help = 'Import outgoing messages from twilio'

    def handle(self, *args, **options):
        import_outgoing_sms()
