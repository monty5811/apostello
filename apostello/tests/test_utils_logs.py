# -*- coding: utf-8 -*-
from ..logs import import_incoming_sms, import_outgoing_sms


class TestImportLogs:
    def test_incoming(self):
        assert 'test credentials used' == import_incoming_sms()

    def test_outgoing(self):
        assert 'test credentials used' == import_outgoing_sms()
