# -*- coding: utf-8 -*-
from datetime import datetime

import pytest
from twilio.rest.exceptions import TwilioRestException

from ..models import *
from ..tasks import *


@pytest.mark.django_db
class TestTasks:
    def test_send_recipient_ok(self, recipients):
        # test sending via recipient
        recipient_send_message_task(recipients['calvin'].id,
                                    "This is a test",
                                    None,
                                    'test')

    def test_send_recipient_blacklist(self, recipients):
        recipient_send_message_task(recipients['john_owen'].id,  # doesn't actually test blacklisted number handling :(
                                    "This is a test to a blacklisted number...",
                                    None,
                                    'test')

    def test_send_fail_number(self, recipients):
        with pytest.raises(TwilioRestException):
            recipient_send_message_task(recipients['thomas_chalmers'].id,
                                        "This is a test to a number that will fail",
                                        None,
                                        'test')

    def test_send_group(self):
        # test sending via group
        group_send_message_task("This is another test",
                                "Test group",
                                'test',
                                eta=None)

    def test_import_incoming_sms_task(self):
        import_incoming_sms_task()

    def test_import_outgoing_sms_task(self):
        import_outgoing_sms_task()

    def test_check_log_consistent(self):
        with pytest.raises(TwilioRestException):
            check_log_consistent('0')

    def test_check_outgoing_log_consistent(self):
        with pytest.raises(TwilioRestException):
            check_recent_outgoing_log('0')

    def test_send_keyword_digest(self, keywords, smsin, users):
        send_keyword_digest()
        assert Keyword.objects.get(keyword='test').last_email_sent_time is not None
        send_keyword_digest()
        # add a new sms:
        sms = SmsInbound.objects.create(content='test message',
                                        time_received=timezone.now(),
                                        sender_name="John Calvin",
                                        sender_num="+447927401749",
                                        matched_keyword="test",
                                        sid='123fasdfdfaw45')
        sms.save()
        keywords['test'].subscribed_to_digest.add(users['staff'])
        keywords['test'].save()
        send_keyword_digest()

    def test_log_msg_in(self, recipients):
        calvin = recipients['calvin']
        p = {'Body': 'New test message',
             'MessageSid': 'thisisreallyauuid',
             'From': calvin.number}
        log_msg_in(p, datetime.now(), calvin.pk)

        assert SmsInbound.objects.filter(content="New test message").count() == 1

    def test_warn_on_blacklist_receipt(self, recipients):
        warn_on_blacklist_receipt(recipients['wesley'].pk, 'stop')
