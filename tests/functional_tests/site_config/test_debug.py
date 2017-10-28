from time import sleep

import pytest
from django.core import mail
from tests.functional_tests.utils import assert_with_timeout

URI = '/config/debug/'


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
@pytest.mark.usefixtures('setup_twilio')
class TestDebug:
    def test_page_content(self, live_server, browser_in):
        browser_in.get(live_server + URI)
        assert URI in browser_in.current_url
        assert "Use these forms" in browser_in.page_source

    def test_email_form(self, live_server, browser_in, driver_wait_time):
        browser_in.get(live_server + URI)
        assert URI in browser_in.current_url
        sleep(driver_wait_time)
        email_input_box = browser_in.find_elements_by_id('email_to')[0]
        email_input_box.clear()
        for k in 'test@example.com':
            email_input_box.send_keys(k)

        body_input_box = browser_in.find_elements_by_id('email_body')[0]
        body_input_box.clear()
        for k in 'test message':
            body_input_box.send_keys(k)

        submit_button = browser_in.find_elements_by_id('email_send_button')[0]
        submit_button.click()

        def _test():
            assert len(mail.outbox) == 1
            assert 'test message' in mail.outbox[0].body

        assert_with_timeout(_test, 5 * driver_wait_time)

    def test_sms_form(self, live_server, browser_in, driver_wait_time, recipients):
        browser_in.get(live_server + URI)
        assert URI in browser_in.current_url
        sleep(driver_wait_time)
        to_input_box = browser_in.find_elements_by_id('sms_to')[0]
        to_input_box.clear()
        to_input_box.send_keys(str(recipients['calvin'].number))

        body_input_box = browser_in.find_elements_by_id('sms_body')[0]
        body_input_box.clear()
        body_input_box.send_keys('test')

        submit_button = browser_in.find_elements_by_id('sms_send_button')[0]
        submit_button.click()

        def _test():
            assert 'AC00000000000000000000000000000000' in browser_in.page_source
            assert 'Error:' in browser_in.page_source
            assert 'Twilio returned the following information:'

        assert_with_timeout(_test, 5 * driver_wait_time)
