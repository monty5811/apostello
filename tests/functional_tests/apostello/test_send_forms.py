from time import sleep

import pytest

from tests.conftest import twilio_vcr

ADHOC_URI = '/send/adhoc/'
GROUP_URI = '/send/group/'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


def click_send(b, wt):
    send_button = b.find_elements_by_class_name('primary')[0]
    send_button.click()
    sleep(wt)
    return b


def add_recipient(b, wt):
    recip_box = b.find_elements_by_class_name('multiple')[0]
    recip_box.click()
    sleep(wt)
    recipient = b.find_elements_by_class_name('item')[-1]
    recipient.click()
    sleep(wt)
    return b


def add_group(b, wt):
    group_box = b.find_elements_by_class_name('selection')[0]
    group_box.click()
    sleep(wt)
    group = b.find_elements_by_class_name('item')[-1]
    group.click()
    sleep(wt)
    return b


def add_content(b, wt):
    content_box = b.find_elements_by_name('content')[0]
    content_box.send_keys('test')
    sleep(wt)
    return b


def add_scheduled_time(b, wt):
    time_box = b.find_elements_by_name('scheduled_time')[0]
    time_box.click()
    sleep(wt)
    plus_button = b.find_elements_by_class_name('increment')[-1]
    plus_button.click()
    plus_button.click()
    set_button = b.find_elements_by_class_name('dtpicker-buttonSet')[0]
    set_button.click()
    sleep(wt)
    return b


@pytest.mark.django_db(transaction=True)
@pytest.mark.slow
@pytest.mark.selenium
class TestSendAdhoc:
    def test_empty_form(
        self, live_server, browser_in, users, driver_wait_time
    ):
        """Test submitting an empty form."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = click_send(b, driver_wait_time)
        assert 'This field is required.' in b.page_source
        assert ADHOC_URI in b.current_url

    @twilio_vcr
    def test_good_form(
        self, live_server, browser_in, users, driver_wait_time, recipients
    ):
        """Test good form submission."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_recipient(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'Please check the logs for verification' in b.page_source
        assert ADHOC_URI in b.current_url

    @twilio_vcr
    def test_scheduled_message(
        self, live_server, browser_in, users, driver_wait_time, recipients
    ):
        """Test good form submission with a scheduled time."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        # add scheduled time
        b = add_scheduled_time(b, driver_wait_time)
        b = add_recipient(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'has been successfully queued' in b.page_source
        assert ADHOC_URI in b.current_url

    def test_too_expensive(
        self, live_server, browser_in, users, driver_wait_time, recipients
    ):
        """Test good form submission but with a too expensive message."""
        user_profile = users['staff'].profile
        user_profile.message_cost_limit = 0.01
        user_profile.save()

        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_recipient(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'cost no more than' in b.page_source
        assert ADHOC_URI in b.current_url

    def test_sms_too_long(
        self, live_server, browser_in, users, driver_wait_time, recipients
    ):
        """Test form submission with a message that is too long."""
        from site_config.models import SiteConfiguration
        s = SiteConfiguration.get_solo()
        s.sms_char_limit = 2
        s.save()
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_recipient(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'You have exceeded' in b.page_source
        assert ADHOC_URI in b.current_url
        s.sms_char_limit = 200
        s.save()


@pytest.mark.django_db(transaction=True)
@pytest.mark.slow
@pytest.mark.selenium
class TestSendGroup:
    def test_empty_form(
        self, live_server, browser_in, users, driver_wait_time
    ):
        """Test submitting an empty form."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = click_send(b, driver_wait_time)
        assert 'This field is required.' in b.page_source
        assert GROUP_URI in b.current_url

    @twilio_vcr
    def test_good_form(
        self, live_server, browser_in, users, driver_wait_time, groups
    ):
        """Test good form submission."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = add_group(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'Please check the logs for verification' in b.page_source
        assert GROUP_URI in b.current_url

    @twilio_vcr
    def test_scheduled_message(
        self, live_server, browser_in, users, driver_wait_time, groups
    ):
        """Test good form submission with a scheduled time."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        # add scheduled time
        b = add_scheduled_time(b, driver_wait_time)
        b = add_group(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'has been successfully queued' in b.page_source
        assert GROUP_URI in b.current_url

    def test_too_expensive(
        self, live_server, browser_in, users, driver_wait_time, groups
    ):
        """Test good form submission but with a too expensive message."""
        user_profile = users['staff'].profile
        user_profile.message_cost_limit = 0.01
        user_profile.save()

        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = add_group(b, driver_wait_time)
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'cost no more than' in b.page_source
        assert GROUP_URI in b.current_url
