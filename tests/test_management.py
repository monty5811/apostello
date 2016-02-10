# -*- coding: utf-8 -*-
import pytest
from django.core.management import call_command
from twilio.rest.exceptions import TwilioRestException


@pytest.mark.django_db
class TestManagementCommands():
    def test_update_sms_name_fields(self, recipients, smsin):
        call_command('update_sms_name_fields')

    def test_import_in(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            call_command('import_incoming_sms')

    def test_import_out(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            call_command('import_outgoing_sms')
