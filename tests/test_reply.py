import pytest

from apostello.models import Recipient
from apostello.reply import InboundSms
from apostello.utils import fetch_default_reply
from tests.conftest import twilio_vcr


@pytest.mark.django_db
class TestConstructReply:
    """Tests apostello.reply:InboundSms.construct_reply function."""

    def test_no_existing_keyword(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'nope'
            }
        )
        reply = msg.construct_reply()
        assert reply == fetch_default_reply('keyword_no_match').replace(
            "%name%", "John"
        )

    def test_existing_keyword(self, recipients, keywords):
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'test msg'
            }
        )
        reply = msg.construct_reply()
        assert reply == "Test custom response with John"

    @twilio_vcr
    def test_name(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'name John Calvin'
            }
        )
        reply = msg.construct_reply()
        assert "John" in str(reply)

    @twilio_vcr
    def test_only_one_name(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'name JohnCalvin'
            }
        )
        reply = msg.construct_reply()
        assert "Something went wrong" in reply

    @twilio_vcr
    def test_stop_start(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'stop '
            }
        )
        reply = msg.construct_reply()
        assert len(reply) == 0
        assert Recipient.objects.get(pk=recipients['calvin'].pk).is_blocking

        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'start '
            }
        )
        reply = msg.construct_reply()
        assert Recipient.objects.get(
            pk=recipients['calvin'].pk
        ).is_blocking is False
        assert 'signing up' in reply

    @twilio_vcr
    def test_existing_keyword_new_contact(self, keywords):
        msg = InboundSms({'From': '+447927401749', 'Body': 'test msg'})
        reply = msg.construct_reply()
        assert reply == "Test custom response with Unknown"

    def test_is_blocking_reply(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['wesley'].number),
                'Body': 'test'
            }
        )
        reply = msg.construct_reply()
        assert len(reply) == 0

    def test_do_not_reply(self, recipients):
        msg = InboundSms(
            {
                'From': str(recipients['beza'].number),
                'Body': 'test'
            }
        )
        reply = msg.construct_reply()
        assert len(reply) == 0

    def test_switch_off_no_keyword_reply(self, recipients):
        from site_config.models import DefaultResponses
        dr = DefaultResponses.get_solo()
        dr.keyword_no_match = ''
        dr.clean()
        dr.save()
        msg = InboundSms(
            {
                'From': str(recipients['calvin'].number),
                'Body': 'test'
            }
        )
        reply = msg.construct_reply()
        assert len(reply) == 0
