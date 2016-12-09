from time import sleep

import pytest

from tests.conftest import twilio_vcr
from apostello.models import SmsOutbound

ADHOC_URI = '/send/adhoc/'
GROUP_URI = '/send/group/'
LOG_URI = '/incoming/'


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
    for x in b.find_elements_by_class_name('item'):
        if x.text == 'John Calvin':
            recipient = x
            break
    recipient.click()
    sleep(wt)
    return b


def add_group(b, wt):
    group_box = b.find_elements_by_class_name('selection')[0]
    group_box.click()
    sleep(wt)
    group = b.find_elements_by_xpath(
        '/html/body/div[3]/div/form/div[2]/div/div[2]/div'
    )[-1]
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

    @twilio_vcr
    def test_prepopulated(
        self, live_server, browser_in, users, driver_wait_time, recipients,
        smsin
    ):
        """Test the reply to button on incoming log."""
        # load the incoming log
        b = load_page(browser_in, driver_wait_time, live_server + LOG_URI)
        # check reply buttons are present
        reply_buttons = b.find_elements_by_class_name('reply')
        assert len(reply_buttons) == len(smsin)
        # test button works
        reply_buttons[0].click()
        sleep(driver_wait_time)
        assert '/send/adhoc/?recipient=' in browser_in.current_url
        # check message sent to correct recipient
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)
        assert 'Please check the logs for verification' in b.page_source
        assert ADHOC_URI in b.current_url
        last_out_sms = SmsOutbound.objects.all()[0]
        assert last_out_sms.recipient.pk == recipients['calvin'].pk

    def test_prepopulated_content(
        self, live_server, browser_in, users, driver_wait_time, recipients
    ):
        """Test the multiple recipients in prepopulated field."""
        # load the incoming log
        uri = '{0}?content={1}'.format(ADHOC_URI, 'DO%20NOT%20REPLY')
        b = load_page(browser_in, driver_wait_time, live_server + uri)
        assert 'DO NOT REPLY' in b.page_source


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
