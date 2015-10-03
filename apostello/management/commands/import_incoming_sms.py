# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import import_incoming_sms


class Command(BaseCommand):
    args = ''
    help = 'Import incoming messages from twilio'

    def handle(self, *args, **options):
        import_incoming_sms()
