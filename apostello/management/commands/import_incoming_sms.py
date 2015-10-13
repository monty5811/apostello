# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import import_incoming_sms


class Command(BaseCommand):
    """
    Checks Twilio's incoming logs for our number and updates the
    database to match.
    """
    args = ''
    help = 'Import incoming messages from twilio'

    def handle(self, *args, **options):
        import_incoming_sms()
