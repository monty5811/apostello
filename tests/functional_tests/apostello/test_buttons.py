from time import sleep

import pytest
from django.contrib.auth.models import User

from apostello import models


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestButton:
    """Test the ajax buttons."""

    @pytest.mark.parametrize(
        "uri,query_set", [
            ('/keyword/all', models.Keyword.objects.all()),
            ('/recipient/all', models.Recipient.objects.all()),
            ('/group/all', models.RecipientGroup.objects.all()),
        ]
    )
    def test_archive_all(
        self, uri, query_set, live_server, browser_in, keywords, recipients,
        groups, smsin, driver_wait_time
    ):
        """Test archive item buttons."""
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # check table is there
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Archive' in table.text
        # toggle a permission
        toggle_buttons = browser_in.find_elements_by_class_name('grey')
        while len(toggle_buttons) > 0:
            toggle_buttons[0].click()
            sleep(driver_wait_time)
            toggle_buttons = browser_in.find_elements_by_class_name('grey')

        for obj in query_set:
            assert obj.is_archived

    def test_keyword_resp_table_archive(
        self, live_server, browser_in, keywords, recipients, groups, smsin,
        driver_wait_time
    ):
        """Test archive sms button."""
        uri = keywords['test'].get_responses_url
        query_set = models.SmsInbound.objects.filter(matched_keyword='test')
        self.test_archive_all(
            uri, query_set, live_server, browser_in, keywords, recipients,
            groups, smsin, driver_wait_time
        )

    def test_unarchive_keyword(
        self, live_server, browser_in, keywords, driver_wait_time
    ):
        """Test restore from archive button."""
        k = models.Keyword.objects.get(keyword='test')
        k.is_archived = True
        k.save()
        uri = k.get_absolute_url
        browser_in.get(live_server + uri)
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        wrench.click()
        button = browser_in.find_elements_by_class_name('positive')[0]
        button.click()
        sleep(driver_wait_time)
        assert 'all' in browser_in.current_url
        k.refresh_from_db()
        assert k.is_archived is False

    def test_display_on_wall_toggle(
        self, live_server, browser_in, smsin, driver_wait_time
    ):
        """Test display on wall buttons."""
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
            sleep(driver_wait_time)
            hidden_buttons = browser_in.find_elements_by_class_name('red')
        sleep(driver_wait_time)
        sms.refresh_from_db()
        assert sms.display_on_wall
        displaying_buttons = browser_in.find_elements_by_class_name('green')
        while len(displaying_buttons) > 0:
            displaying_buttons[0].click()
            sleep(driver_wait_time)
            displaying_buttons = browser_in.find_elements_by_class_name(
                'green'
            )
        sleep(driver_wait_time)
        sms.refresh_from_db()
        assert sms.display_on_wall is False

    def test_reingest_button(
        self, live_server, browser_in, smsin, driver_wait_time
    ):
        """Test reingest sms button."""
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
        sleep(driver_wait_time)
        sms.refresh_from_db()
        assert sms.matched_keyword == 'test'

    def test_keyword_resp_table_dealt_with(
        self, live_server, browser_in, smsin, keywords, driver_wait_time
    ):
        browser_in.get(live_server + keywords['test'].get_absolute_url)
        for button in browser_in.find_elements_by_class_name('positive'):
            browser_in.execute_script(
                "return arguments[0].scrollIntoView();", button
            )
            button.click()
        sleep(driver_wait_time)
        for k in models.SmsInbound.objects.filter(matched_keyword='test'):
            assert k.dealt_with is False

    def test_archive_without_permission(
        self, live_server, browser_in, recipients, driver_wait_time
    ):
        # remove priveleges:
        u = User.objects.get(username='test')
        u.is_staff = False
        u.is_superuser = False
        u.save()
        p = u.profile
        p.can_archive = False
        p.save()
        # open page:
        uri = '/recipient/all/'
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        sleep(driver_wait_time)
        # archive (should fail and show a popup):
        toggle_buttons = browser_in.find_elements_by_class_name('grey')
        toggle_buttons[0].click()
        sleep(driver_wait_time)
        alert = browser_in.switch_to_alert()
        alert.accept()
