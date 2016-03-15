from time import sleep

import pytest

from apostello import models


@pytest.mark.django_db
@pytest.mark.slow
class TestButton:
    @pytest.mark.parametrize(
        "uri,query_set", [
            ('/keyword/all', models.Keyword.objects.all()),
            ('/recipient/all', models.Recipient.objects.all()),
            ('/group/all', models.RecipientGroup.objects.all()),
        ]
    )
    def test_archive_all(
        self, uri, query_set, live_server, browser_in, users, keywords,
        recipients, groups, smsin
    ):
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # check table is there
        sleep(3)
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Archive' in table.text
        # toggle a permission
        toggle_buttons = browser_in.find_elements_by_class_name('grey')
        while len(toggle_buttons) > 0:
            toggle_buttons[0].click()
            sleep(2)
            toggle_buttons = browser_in.find_elements_by_class_name('grey')

        for obj in query_set:
            assert obj.is_archived

    def test_keyword_resp_table_archive(self, live_server, browser_in, users,
                                        keywords, recipients, groups, smsin):
        uri = keywords['test'].get_responses_url
        query_set = models.SmsInbound.objects.filter(matched_keyword='test')
        self.test_archive_all(
            uri, query_set, live_server, browser_in, users, keywords,
            recipients, groups, smsin
        )

    def test_unarchive_keyword(self, live_server, browser_in, keywords):
        k = models.Keyword.objects.get(keyword='test')
        k.is_archived = True
        k.save()
        uri = k.get_absolute_url
        browser_in.get(live_server + uri)
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        wrench.click()
        button = browser_in.find_elements_by_class_name('positive')[0]
        button.click()
        sleep(2)
        assert 'all' in browser_in.current_url
        k.refresh_from_db()
        assert k.is_archived is False

    def test_display_on_wall_toggle(self, live_server, browser_in, users,
                                    smsin):
        sms = models.SmsInbound.objects.get(sid=smsin['sms1'].sid)
        sms.display_on_wall = False
        uri = '/incoming/curate_wall/'
        browser_in.get(live_server + uri)
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Hidden' in table.text
        hidden_buttons = browser_in.find_elements_by_class_name('red')
        while len(hidden_buttons) > 0:
            hidden_buttons[0].click()
            sleep(2)
            hidden_buttons = browser_in.find_elements_by_class_name('red')
        sleep(2)
        sms.refresh_from_db()
        assert sms.display_on_wall
        displaying_buttons = browser_in.find_elements_by_class_name('green')
        while len(displaying_buttons) > 0:
            displaying_buttons[0].click()
            sleep(2)
            displaying_buttons = browser_in.find_elements_by_class_name(
                'green')
        sleep(2)
        sms.refresh_from_db()
        assert sms.display_on_wall is False

    def test_reingest_button(self, live_server, browser_in, users, smsin):
        sms = models.SmsInbound.objects.create(
            sid='tmp_____',
            content='test',
            matched_keyword='',
            matched_colour='',
            matched_link='',
        )
        sms.save()
        browser_in.get(live_server + '/incoming/')
        for button in browser_in.find_elements_by_class_name('blue'):
            button.click()
        sleep(2)
        sms.refresh_from_db()
        assert sms.matched_keyword == 'test'

    def test_keyword_resp_table_dealt_with(self, live_server, browser_in,
                                           users, smsin, keywords):
        browser_in.get(live_server + keywords['test'].get_absolute_url)
        for button in browser_in.find_elements_by_class_name('positive'):
            browser_in.execute_script("return arguments[0].scrollIntoView();",
                                      button)
            button.click()
        sleep(2)
        for k in models.SmsInbound.objects.filter(matched_keyword='test'):
            assert k.dealt_with is False
