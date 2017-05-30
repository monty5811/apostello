from datetime import datetime

import pytest
from tests.conftest import twilio_vcr
from twilio.base.exceptions import TwilioRestException

from apostello.models import *
from apostello.tasks import *


@pytest.mark.django_db
class TestTasks:
    @twilio_vcr
    def test_send_recipient_ok(self, recipients):
        # test sending via recipient
        recipient_send_message_task(recipients['calvin'].id, "This is a test", None, 'test')

    @twilio_vcr
    def test_send_recipient_blacklist(self, recipients):
        recipient_send_message_task(
            recipients['john_owen'].id,  # doesn't actually test blacklisted number handling :(
            "This is a test to a blacklisted number...",
            None,
            'test'
        )

    @twilio_vcr
    def test_send_fail_number(self, recipients):
        with pytest.raises(TwilioRestException) as e_info:
            recipient_send_message_task(
                recipients['thomas_chalmers'].id, "This is a test to a number that will fail", None, 'test'
            )
        assert "is not a mobile" in str(e_info.value)

    @twilio_vcr
    def test_send_group(self):
        # test sending via group
        group_send_message_task("This is another test", "Test group", 'test', eta=None)

    @twilio_vcr
    def test_check_log_consistent(self):
        check_incoming_log()

    @twilio_vcr
    def test_check_outgoing_log_consistent(self):
        check_outgoing_log()

    def test_send_keyword_digest(self, keywords, smsin, users):
        send_keyword_digest()
        assert Keyword.objects.get(keyword='test').last_email_sent_time is not None
        send_keyword_digest()
        # add a new sms:
        sms = SmsInbound.objects.create(
            content='test message',
            time_received=timezone.now(),
            sender_name="John Calvin",
            sender_num="+447927401749",
            matched_keyword="test",
            sid='123fasdfdfaw45'
        )
        sms.save()
        keywords['test'].subscribed_to_digest.add(users['staff'])
        keywords['test'].save()
        send_keyword_digest()

    @twilio_vcr
    def test_log_msg_in(self, recipients):
        calvin = recipients['calvin']
        p = {'Body': 'New test message', 'MessageSid': 'thisisreallyauuid', 'From': calvin.number}
        log_msg_in(p, timezone.now(), calvin.pk)

        assert SmsInbound.objects.filter(content="New test message").count() == 1

    def test_warn_on_blacklist_receipt(self, recipients):
        blacklist_notify(recipients['wesley'].pk, 'stop it', 'stop')

    def test_add_new_ppl_to_groups(self, groups):
        from site_config.models import SiteConfiguration
        config = SiteConfiguration.get_solo()
        grp = groups['empty_group']
        assert grp.recipient_set.count() == 0
        config.auto_add_new_groups.add(grp)
        config.save()
        new_c = Recipient.objects.create(
            first_name='test',
            last_name='new',
            number='+44715620857',
        )
        assert grp.recipient_set.count() == 1
        assert new_c in grp.recipient_set.all()
