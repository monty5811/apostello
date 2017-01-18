from time import sleep

from django.contrib.auth.models import User
from django.core import mail
from tests.conftest import twilio_vcr

import pytest
from apostello.models import SmsOutbound

URI = '/config/first_run/'


@pytest.mark.django_db(transaction=True)
@pytest.mark.slow
@pytest.mark.selenium
class TestFirstRun:
    def test_page_content(self, live_server, browser):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        assert "Welcome" in browser.page_source
        assert "DJANGO_EMAIL_HOST" in browser.page_source
        assert "TWILIO_AUTH_TOKEN" in browser.page_source

    def test_email_form(self, live_server, browser, driver_wait_time):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        email_input_box = browser.find_elements_by_id('email_to')[0]
        email_input_box.clear()
        for k in 'test@example.com':
            email_input_box.send_keys(k)

        body_input_box = browser.find_elements_by_id('email_body')[0]
        body_input_box.clear()
        for k in 'test message':
            body_input_box.send_keys(k)

        submit_button = browser.find_elements_by_id('email_send_button')[0]
        submit_button.click()

        sleep(driver_wait_time)
        assert len(mail.outbox) == 1
        assert 'test message' in mail.outbox[0].body

    # @twilio_vcr
    def test_sms_form(
        self, live_server, browser, driver_wait_time, recipients
    ):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        to_input_box = browser.find_elements_by_id('sms_to')[0]
        to_input_box.clear()
        to_input_box.send_keys(str(recipients['calvin'].number))

        body_input_box = browser.find_elements_by_id('sms_body')[0]
        body_input_box.clear()
        body_input_box.send_keys('test')

        submit_button = browser.find_elements_by_id('sms_send_button')[0]
        submit_button.click()

        sleep(driver_wait_time)
        assert 'AC00000000000000000000000000000000' in browser.page_source
        assert 'Error:' in browser.page_source
        assert 'Twilio returned the following information:'

    def test_user_form(self, live_server, browser, driver_wait_time):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        email_input_box = browser.find_elements_by_id('admin_email')[0]
        email_input_box.clear()
        email_input_box.send_keys('test@example.com')

        pass1_input_box = browser.find_elements_by_id('admin_pass1')[0]
        pass1_input_box.clear()
        pass1_input_box.send_keys('password')

        pass2_input_box = browser.find_elements_by_id('admin_pass2')[0]
        pass2_input_box.clear()
        pass2_input_box.send_keys('password')

        submit_button = browser.find_elements_by_id('create_admin_button')[0]
        submit_button.click()

        sleep(driver_wait_time)
        assert User.objects.count() == 1
        browser.get(live_server + URI)
        assert URI not in browser.current_url
