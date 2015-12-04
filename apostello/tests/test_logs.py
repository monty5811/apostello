# -*- coding: utf-8 -*-
import types
from datetime import datetime

import pytest
from django.conf import settings
from twilio.rest.exceptions import TwilioRestException

from apostello import logs, models


class MockMsg:
    def __init__(self, from_):
        self.sid = 'a' * 36
        self.body = 'test message'
        self.from_ = from_
        self.to = settings.to = '447922537999'
        self.date_created = datetime.now()
        self.date_sent = datetime.now()


class TestImportLogs:
    """
    Test log imports.

    Unable to test this properly as Twilio raises an exception when test
    credentials are used.
    """
    def test_all_incoming(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            logs.check_incoming_log(fetch_all=True)

    def test_incoming_consistent(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            logs.check_incoming_log(fetch_all=False)

    def test_all_outgoing(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            logs.check_outgoing_log(fetch_all=True)

    def test_outgoing_consistent(self):
        # TODO mock response from Twilio so we can test this
        with pytest.raises(TwilioRestException):
            logs.check_outgoing_log(fetch_all=False)


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


class TestFetchingClients:
    def test_fetch_all_in(self):
        i = logs.fetch_generator('in')
        assert isinstance(i, types.GeneratorType)
        with pytest.raises(TwilioRestException):
            for msg in i:
                str(i)

    def test_fetch_all_out(self):
        i = logs.fetch_generator('out')
        assert isinstance(i, types.GeneratorType)
        with pytest.raises(TwilioRestException):
            for msg in i:
                str(i)

    def test_fetch_all_bad(self):
        assert isinstance(logs.fetch_generator('nope'), list)

    def test_fetch_page_in(self):
        with pytest.raises(TwilioRestException):
            assert isinstance(logs.fetch_list('in', 0), list)

    def test_fetch_page_out(self):
        with pytest.raises(TwilioRestException):
            assert isinstance(logs.fetch_list('out', 0), list)

    def test_fetch_page_bad(self):
        assert isinstance(logs.fetch_list('nope', 0), list)
