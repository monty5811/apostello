# -*- coding: utf-8 -*-
import types
from datetime import datetime

import pytest
from django.conf import settings

from apostello import logs, models
from tests.conftest import twilio_vcr


class MockMsg:
    def __init__(self, from_):
        self.sid = 'a' * 36
        self.body = 'test message'
        self.from_ = from_
        self.to = settings.to = '447922537999'
        self.date_created = datetime.now()
        self.date_sent = datetime.now()


@pytest.mark.django_db
class TestImportLogs:
    """
    Test log imports.

    Unable to test this properly as Twilio raises an exception when test
    credentials are used.
    """

    @twilio_vcr
    def test_all_incoming(self):
        logs.check_incoming_log()


    @twilio_vcr
    def test_all_outgoing(self):
        logs.check_outgoing_log()


@pytest.mark.django_db
class TestSmsHandlers:
    def test_handle_incoming_sms(self):
        msg = MockMsg('447922537999')
        cnp = logs.handle_incoming_sms(msg)
        assert cnp is True
        assert models.SmsInbound.objects.all()[0].content == msg.body

        cnp = logs.handle_incoming_sms(msg)
        assert cnp is None

    def test_handle_outgoing_sms(self):
        msg = MockMsg('447932537999')
        cnp = logs.handle_outgoing_sms(msg)
        assert cnp is True
        assert models.SmsOutbound.objects.all()[0].content == msg.body

        cnp = logs.handle_outgoing_sms(msg)
        assert cnp is None


@pytest.mark.django_db
class TestFetchingClients:
    @twilio_vcr
    def test_fetch_all_in(self):
        i = logs.fetch_generator('in')
        assert isinstance(i, types.GeneratorType)
        for msg in i:
            str(i)

    @twilio_vcr
    def test_fetch_all_out(self):
        i = logs.fetch_generator('out')
        assert isinstance(i, types.GeneratorType)
        for msg in i:
            str(i)

    @twilio_vcr
    def test_fetch_all_bad(self):
        assert isinstance(logs.fetch_generator('nope'), list)
