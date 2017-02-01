# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import check_incoming_log


class Command(BaseCommand):
    """
    Checks Twilio's incoming logs for our number and updates the
    database to match.
    """
    args = ''
    help = 'Import incoming messages from twilio'

    def handle(self, *args, **options):
        """Handle the command."""
        check_incoming_log()
