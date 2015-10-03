# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import import_outgoing_sms


class Command(BaseCommand):
    args = ''
    help = 'Import outgoing messages from twilio'

    def handle(self, *args, **options):
        import_outgoing_sms()
