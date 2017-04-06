# -*- coding: utf-8 -*-
from datetime import datetime

import pytest
from django.core.exceptions import ValidationError
from django.utils import timezone

from apostello.models import Keyword, SmsInbound
from apostello.utils import fetch_default_reply


@pytest.mark.django_db
class TestKeywords():
    def test_display(self, keywords):
        assert str(keywords['test']) == "test"

    def test_disabled_reply(self, keywords, recipients):
        assert keywords['test_do_not_reply'
                        ].construct_reply(recipients['calvin']) == ''

    def test_expired(self, recipients, keywords):
        assert keywords['test_expired'].construct_reply(
            recipients['calvin']
        ) == recipients['calvin'].personalise(
            fetch_default_reply('default_no_keyword_not_live')
            .replace("%keyword%", str(keywords['test_expired']))
        )

    def test_early(self, recipients, keywords):
        assert keywords['test_early'].construct_reply(
            recipients['calvin']
        ) == recipients['calvin'].personalise(
            fetch_default_reply('default_no_keyword_not_live')
            .replace("%keyword%", str(keywords['test_early']))
        )

    def test_no_end(self, recipients, keywords):
        assert keywords['test_no_end'].construct_reply(recipients['calvin']
                                                       ) == "Will always reply"

    def test_custom_reply(self, recipients, keywords):
        assert keywords['test'].construct_reply(
            recipients['calvin']
        ) == "Test custom response with John"

    def test_no_custom_reply(self, recipients, keywords):
        assert keywords['test2'].construct_reply(
            recipients['calvin']
        ) == recipients['calvin'].personalise(
            fetch_default_reply('default_no_keyword_auto_reply')
        )

    def test_deactivated_custom_reply(self, recipients, keywords):
        assert keywords['test_deac_resp'].construct_reply(
            recipients['calvin']
        ) == "Too slow, Joe!"

    def test_deactivated_custom_reply_no_deac_time(self, recipients, keywords):
        assert keywords['test_deac_resp_fail'
                        ].construct_reply(recipients['calvin']) == "Hi!"

    def test_too_early_custom_reply(self, recipients, keywords):
        assert keywords['test_early_with_response'].construct_reply(
            recipients['calvin']
        ) == "This is far too early"

    def test_fetch_matched_responses(self, keywords, smsin):
        assert len(keywords['test'].fetch_matches()) == 2
        assert str(keywords['test'].fetch_matches()[0]) == str(
            SmsInbound.objects.filter(content="test message")[0]
        )

    def test_fetch_archived_matched_responses(self, keywords, smsin):
        assert len(keywords['test'].fetch_archived_matches()) == 1
        assert str(keywords['test'].fetch_archived_matches()[0]) == str(
            SmsInbound.objects.filter(content="archived message")[0]
        )

    def test_num_matches(self, keywords, smsin):
        assert keywords['test'].num_matches == 2

    def test_num_archived_matches(self, keywords, smsin):
        assert keywords['test'].num_archived_matches == 1

    def test_archiving(self, keywords, smsin):
        keywords['test'].archive()
        assert keywords['test'].is_archived
        assert len(keywords['test'].fetch_matches()) == 0

    def test_is_locked(self, keywords, users):
        assert keywords['test'].is_locked
        assert keywords['test2'].is_locked is False

    def test_access(self, keywords, users):
        assert keywords['test'].can_user_access(users['notstaff2']) is False
        assert keywords['test'].can_user_access(users['notstaff'])
        assert keywords['test'].can_user_access(users['staff'])

    def test_match(self, keywords):
        keyword_ = Keyword.match("test matching")
        assert str(keyword_) == "test"
        assert type(keyword_) == Keyword

    def test_no_match(self, keywords):
        assert Keyword.match("nope") == 'No Match'

    def test_get_log_link_keyword(self, keywords):
        assert Keyword.get_log_link(keywords['test']
                                    ) == '/keyword/responses/test/'

    def test_lookup_colour_test(self, keywords):
        assert Keyword.lookup_colour('test') == '#098f6b'

    def test_get_log_link_str(self, keywords):
        assert Keyword.get_log_link('test_no_link') == '#'

    def test_stop(self):
        assert Keyword.match("Stop it!") == 'stop'
        assert Keyword.match("stop    ") == 'stop'
        assert Keyword.match("\nSTOP    ") == 'stop'
        for x in ["stopall", "unsubscribe", "cancel", "end", "quit"]:
            assert Keyword.match("{0}".format(x)) == 'stop'

    def test_start(self):
        for x in ["start", "yes"]:
            assert Keyword.match("{0}".format(x)) == 'start'

    def test_info(self):
        for x in ["help", "info"]:
            assert Keyword.match("{0}".format(x)) == 'info'

    def test_name(self):
        assert Keyword.match("name John Calvin") == 'name'

    def test_empty(self):
        assert Keyword.match("") == "No Match"

    def test_lookup_colour_stop(self):
        assert Keyword.lookup_colour('stop') == '#FFCDD2'

    def test_lookup_colour_name(self):
        assert Keyword.lookup_colour('name John Calvin') == '#BBDEFB'

    def test_lookup_colour_none(self):
        assert Keyword.lookup_colour('nope') == '#B6B6B6'

    def test_dates_wrong_way_round(self):
        k = Keyword.objects.create(
            keyword="time_test",
            description="This is an active test keyword with no "
            "custom response",
            custom_response="",
            activate_time=timezone.make_aware(
                datetime.strptime('Jun 1 2000  1:33PM', '%b %d %Y %I:%M%p'),
                timezone.get_current_timezone()
            ),
            deactivate_time=timezone.make_aware(
                datetime.strptime('Jun 1 1970  1:33PM', '%b %d %Y %I:%M%p'),
                timezone.get_current_timezone()
            )
        )
        with pytest.raises(ValidationError):
            k.full_clean()
