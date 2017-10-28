from time import sleep

import pytest
from flaky import flaky
from selenium.common.exceptions import ElementNotVisibleException
from selenium.webdriver.common.keys import Keys
from tests.conftest import MAX_RUNS, twilio_vcr
from tests.functional_tests.utils import assert_with_timeout, click_and_wait

from apostello.models import SmsOutbound
from site_config.models import SiteConfiguration

ADHOC_URI = '/send/adhoc/'
GROUP_URI = '/send/group/'
LOG_URI = '/incoming/'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


def click_send(b, wt):
    send_button = b.find_element_by_id('send_button')
    if not send_button.is_enabled():
        sleep(wt * 3)
    click_and_wait(send_button, wt)
    return b


def add_recipient(b, wt):
    for x in b.find_elements_by_id('contactItem'):
        if x.text == 'John Calvin':
            recipient = x
            break
    click_and_wait(recipient, wt)
    return b


def add_group(b, wt):
    group = b.find_elements_by_id('groupItem')[-1]
    click_and_wait(group, wt)
    return b


def add_content(b, wt):
    t = 0
    max_t = 10 * wt
    while t <= max_t:
        try:
            content_box = b.find_elements_by_name('content')[0]
            content_box.send_keys('test')
            break
        except ElementNotVisibleException as e:
            if t < max_t:
                sleep(wt)
                t = t + wt
            else:
                raise (e)
    return b


def add_scheduled_time(b, wt):
    time_box = b.find_elements_by_name('scheduled_time')[0]
    click_and_wait(time_box, wt)
    time_box.send_keys('2127-05-25 16:03')
    time_box.send_keys(Keys.TAB)
    return b


def add_content_and_recipient(b, wt):
    b = add_content(b, wt)
    b = add_recipient(b, wt)
    return b


def add_content_and_group(b, wt):
    b = add_content(b, wt)
    b = add_group(b, wt)
    return b


@flaky(max_runs=MAX_RUNS)
@pytest.mark.slow
@pytest.mark.django_db
@pytest.mark.selenium
@pytest.mark.usefixtures('setup_twilio')
class TestSendAdhoc():
    def test_empty_form(self, live_server, browser_in, users, driver_wait_time):
        """Test submitting an empty form."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        send_button = b.find_element_by_id('send_button')
        assert send_button.text == 'Send ($0.00)'
        assert send_button.get_attribute('disabled') == 'true'

    @twilio_vcr
    def test_good_form(self, live_server, browser_in, users, driver_wait_time, recipients):
        """Test good form submission."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_content_and_recipient(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'Please check the logs for verification' in b.page_source
        assert '/outgoing/' in b.current_url

    @twilio_vcr
    def test_scheduled_message(self, live_server, browser_in, users, driver_wait_time, recipients):
        """Test good form submission with a scheduled time."""
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        # add scheduled time
        b = add_scheduled_time(b, driver_wait_time)
        b = add_content_and_recipient(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        def _test():
            assert '/scheduled/sms/' in b.current_url

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_too_expensive(self, live_server, browser_in, users, driver_wait_time, recipients):
        """Test good form submission but with a too expensive message."""
        user_profile = users['staff'].profile
        user_profile.message_cost_limit = 0.01
        user_profile.save()

        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_content_and_recipient(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'cost no more than' in b.page_source
        assert ADHOC_URI in b.current_url

    def test_sms_too_long(self, live_server, browser_in, users, driver_wait_time, recipients):
        """Test form submission with a message that is too long."""
        from site_config.models import SiteConfiguration
        s = SiteConfiguration.get_solo()
        s.sms_char_limit = 2
        s.save()
        b = load_page(browser_in, driver_wait_time, live_server + ADHOC_URI)
        b = add_content_and_recipient(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'You have exceeded' in b.page_source
        assert ADHOC_URI in b.current_url
        s.sms_char_limit = 200
        s.save()

    @twilio_vcr
    def test_prepopulated(self, live_server, browser_in, users, driver_wait_time, recipients, smsin):
        """Test the reply to button on incoming log."""
        # load the incoming log
        b = load_page(browser_in, driver_wait_time, live_server + LOG_URI)
        # check reply buttons are present
        reply_buttons = b.find_elements_by_class_name('fa-reply')
        assert len(reply_buttons) == len(smsin)
        # test button works
        click_and_wait(reply_buttons[0], driver_wait_time)
        assert '/send/adhoc/' in browser_in.current_url
        assert 'recipients=[' in browser_in.current_url
        # check message sent to correct recipient
        b = add_content(b, driver_wait_time)
        b = click_send(b, driver_wait_time)
        assert 'Please check the logs for verification' in b.page_source
        assert '/outgoing/' in b.current_url
        last_out_sms = SmsOutbound.objects.all()[0]
        assert last_out_sms.recipient.pk == recipients['calvin'].pk

    def test_prepopulated_content(self, live_server, browser_in, users, driver_wait_time, recipients):
        """Test the multiple recipients in prepopulated field."""
        # load the incoming log
        uri = '{0}?content={1}'.format(ADHOC_URI, 'DO%20NOT%20REPLY')
        b = load_page(browser_in, driver_wait_time, live_server + uri)
        content_box = b.find_element_by_id('id_content')
        assert 'DO NOT REPLY' == content_box.get_attribute('value')


@flaky(max_runs=MAX_RUNS)
@pytest.mark.slow
@pytest.mark.django_db
@pytest.mark.selenium
@pytest.mark.usefixtures('setup_twilio')
class TestSendGroup:
    def test_empty_form(self, live_server, browser_in, users, driver_wait_time, groups):
        """Test submitting an empty form."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        send_button = b.find_element_by_id('send_button')
        assert send_button.text == 'Send ($0.00)'
        assert send_button.get_attribute('disabled') == 'true'

    @twilio_vcr
    def test_good_form(self, live_server, browser_in, users, driver_wait_time, groups):
        """Test good form submission."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = add_content_and_group(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'Please check the logs for verification' in b.page_source
        assert '/outgoing/' in b.current_url

    @twilio_vcr
    def test_scheduled_message(self, live_server, browser_in, users, driver_wait_time, groups):
        """Test good form submission with a scheduled time."""
        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = add_content_and_group(b, driver_wait_time)
        b = add_scheduled_time(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert '/scheduled/sms/' in b.current_url

    def test_too_expensive(self, live_server, browser_in, users, driver_wait_time, groups):
        """Test good form submission but with a too expensive message."""
        user_profile = users['staff'].profile
        user_profile.message_cost_limit = 0.01
        user_profile.save()

        b = load_page(browser_in, driver_wait_time, live_server + GROUP_URI)
        b = add_content_and_group(b, driver_wait_time)
        b = click_send(b, driver_wait_time)

        assert 'cost no more than' in b.page_source
        assert GROUP_URI in b.current_url
