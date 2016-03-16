# -*- coding: utf-8 -*-
from datetime import datetime

import pytest

from tests.conftest import twilio_vcr


@pytest.mark.django_db
class TestRecipient:
    def test_display(self, recipients):
        assert str(recipients['calvin']) == 'John Calvin'

    def test_personalise(self, recipients):
        assert recipients['calvin'].personalise('Hi %name%!') == 'Hi John!'

    def test_get_abs_url(self, recipients):
        assert recipients[
            'calvin'
        ].get_absolute_url == '/recipient/edit/{0}/'.format(
            recipients['calvin'].pk
        )

    def test_archiving(self, recipients):
        recipients['calvin'].archive()
        assert recipients['calvin'].is_archived
        assert len(recipients['calvin'].groups.all()) == 0

    @twilio_vcr
    def test_send_now(self, recipients):
        recipients['calvin'].send_message('test')

    @twilio_vcr
    def test_send_eta(self, recipients):
        recipients['calvin'].send_message('test', eta=datetime.now())

    @twilio_vcr
    def test_send_blacklist(self, recipients):
        recipients['wesley'].send_message('test')

    def test_send_archived(self, recipients):
        recipients['knox'].send_message('test')
