from datetime import datetime, timedelta

import pytest
from tests.conftest import onebody_vcr, twilio_vcr
from twilio.base.exceptions import TwilioRestException

from apostello.models import *
from apostello.tasks import *
from site_config.models import SiteConfiguration


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

    def test_cleanup_expired_sms(self, smsin):
        config = SiteConfiguration.get_solo()
        config.sms_expiration_date = None
        config.save()
        for sms in SmsInbound.objects.all():
            # move back in time so they can be deleted
            sms.time_received = sms.time_received - timedelta(days=5)
            sms.save()
        cleanup_expired_sms()
        assert SmsInbound.objects.count() == len(smsin)
        config = SiteConfiguration.get_solo()
        config.sms_expiration_date = timezone.localdate()
        config.save()
        cleanup_expired_sms()
        assert SmsInbound.objects.count() == 0

    def test_add_new_ppl_to_groups(self, groups):
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

    @onebody_vcr
    def test_onebody_csv(self):
        """Test fetching people from onebody."""
        pull_onebody_csv()
        assert RecipientGroup.objects.count() == 1
        assert Recipient.objects.count() == 7
        assert RecipientGroup.objects.get(name='[onebody]').recipient_set.count() == 7

    @twilio_vcr
    def test_twilio_delete_sms_in(self, smsin):
        n_in = SmsInbound.objects.count()
        smsin['sms1'].delete_from_twilio()
        assert n_in - 1 == SmsInbound.objects.count()

    @twilio_vcr
    def test_twilio_delete_sms_out(self, smsout):
        n_out = SmsOutbound.objects.count()
        smsout['smsout'].delete_from_twilio()
        assert n_out - 1 == SmsOutbound.objects.count()
