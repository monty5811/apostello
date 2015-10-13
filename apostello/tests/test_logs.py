# -*- coding: utf-8 -*-
from ..logs import import_incoming_sms, import_outgoing_sms


class TestImportLogs:
    """
    Test log import.

    Unable to test this properly as Twilio raises an exception when test
    credentials are used.
    """
    def test_incoming(self):
        assert 'test credentials used' == import_incoming_sms()

    def test_outgoing(self):
        assert 'test credentials used' == import_outgoing_sms()
