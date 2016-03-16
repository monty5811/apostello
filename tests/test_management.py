# -*- coding: utf-8 -*-
import pytest
from django.core.management import call_command

from tests.conftest import twilio_vcr


@pytest.mark.django_db
class TestManagementCommands():
    def test_update_sms_name_fields(self, recipients, smsin):
        call_command('update_sms_name_fields')

    @twilio_vcr
    def test_import_in(self):
        call_command('import_incoming_sms')

    @twilio_vcr
    def test_import_out(self):
        call_command('import_outgoing_sms')
