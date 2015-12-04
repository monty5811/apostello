# -*- coding: utf-8 -*-
from django.core.management.base import BaseCommand

from apostello.logs import check_outgoing_log


class Command(BaseCommand):
    """
    Checks Twilio's outgoing logs for our number and updates the
    database to match.
    """
    args = ''
    help = 'Import outgoing messages from twilio'

    def handle(self, *args, **options):
        check_outgoing_log(fetch_all=True)
