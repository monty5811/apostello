# -*- coding: utf-8 -*-
import pytest

from apostello.models import Keyword
from apostello.reply import (get_person_or_ask_for_name, keyword_replier,
                             reply_to_incoming)
from apostello.utils import fetch_default_reply


@pytest.mark.django_db
class TestKeywordReplier:
    """Tests apostello.reply.keyword_replier function."""

    def test_no_existing_keyword(self, recipients):
        assert keyword_replier(
            None, recipients[
                'calvin'
            ]
        ) == fetch_default_reply('keyword_no_match').replace(
            "%name%", "John"
        )

    def test_existing_keyword(self, recipients, keywords):
        assert keyword_replier(keywords['test'], recipients['calvin']) == "Test custom response with John"


@pytest.mark.django_db
class TestReply:
    """Tests apostello.reply.reply_to_incoming fn."""

    def test_name(self, recipients):
        sms_body = "name John Calvin"
        k_obj = Keyword.match(sms_body)
        reply = reply_to_incoming(recipients['calvin'], recipients['calvin'].number, sms_body, k_obj)
        assert "John" in str(reply)

    def test_only_one_name(self, recipients):
        sms_body = "name JohnCalvin"
        k_obj = Keyword.match(sms_body)
        r_new = reply_to_incoming(recipients['calvin'], recipients['calvin'].number, sms_body, k_obj)
        assert "Something went wrong" in str(r_new)

    def test_stop_start(self, recipients):
        sms_body = "stop "
        k_obj = Keyword.match(sms_body)
        reply_to_incoming(recipients['calvin'], recipients['calvin'].number, sms_body, k_obj)
        assert recipients['calvin'].is_blocking

        sms_body = "start"
        k_obj = Keyword.match(sms_body)
        reply_to_incoming(recipients['calvin'], recipients['calvin'].number, sms_body, k_obj)
        assert recipients['calvin'].is_blocking is False

    def test_other(self, recipients):
        sms_body = "test message"
        k_obj = Keyword.match(sms_body)
        r_new = reply_to_incoming(recipients['calvin'], recipients['calvin'].number, sms_body, k_obj)
        assert "" in str(r_new)


@pytest.mark.django_db
class TestGetOrAskPerson():
    """Tests apostello.reply.get_person_or_ask_for_name fn."""

    def test_known(self, recipients):
        assert recipients['calvin'] == get_person_or_ask_for_name('+447927401749', 'hello', 'hello')

    def test_unknown(self):
        person_from = get_person_or_ask_for_name('+447928401749', 'hello', 'hello')
        assert 'Unknown' == person_from.first_name

    def test_unknown_name_keyword(self):
        person_from = get_person_or_ask_for_name('+447928521749', 'name', 'name')
        assert 'Unknown' == person_from.first_name
