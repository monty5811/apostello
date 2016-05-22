from time import sleep

from django.contrib.auth.models import User
from django.core import mail
from tests.conftest import twilio_vcr

import pytest
from apostello.models import SmsOutbound

URI = '/config/first_run/'


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestFirstRun:
    def test_page_content(self, live_server, browser):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        assert "Welcome" in browser.page_source
        assert "DJANGO_EMAIL_HOST" in browser.page_source
        assert "TWILIO_AUTH_TOKEN" in browser.page_source

    def disabled_test_email_form(self, live_server, browser, driver_wait_time):
        # TODO fix test - click does not work!
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        email_input_box = browser.find_elements_by_css_selector(
            '#send_test_email > div > form > div.fields > div.four.wide.field > input[type="email"]'
        )[0]
        email_input_box.clear()
        email_input_box.send_keys('test@example.com')

        body_input_box = browser.find_elements_by_css_selector(
            '#send_test_email > div > form > div.fields > div.twelve.wide.field > input[type="text"]'
        )[0]
        body_input_box.clear()
        body_input_box.send_keys('test message')

        submit_button = browser.find_elements_by_css_selector(
            '#send_test_email > div > form > button'
        )[0]
        import pdb
        pdb.set_trace()
        submit_button.click()

        sleep(driver_wait_time)
        assert len(mail.outbox) == 1
        assert 'test message' in mail.outbox[0].body

    @twilio_vcr
    def disabled_test_sms_form(
        self, live_server, browser, driver_wait_time, recipients
    ):
        # TODO fix test - click does not work!
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        to_input_box = browser.find_elements_by_css_selector(
            '#send_test_sms > div > form > div > div.four.wide.field > input[type="email"]'
        )[0]
        to_input_box.clear()
        to_input_box.send_keys(str(recipients['calvin'].number))

        body_input_box = browser.find_elements_by_css_selector(
            '#send_test_sms > div > form > div > div.twelve.wide.field > input[type="text"]'
        )[0]
        body_input_box.clear()
        body_input_box.send_keys('test')

        submit_button = browser.find_elements_by_css_selector(
            '#send_test_sms > div > form > button'
        )[0]
        submit_button.click()

        sleep(driver_wait_time)
        assert SmsOutbound.objects.count() == 1

    def disabled_test_user_form(self, live_server, browser, driver_wait_time):
        # TODO fix test - click does not work!
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        email_input_box = browser.find_elements_by_css_selector(
            '#create_admin_user > div > form > div > div.eight.wide.field > input[type="email"]'
        )[0]
        email_input_box.clear()
        email_input_box.send_keys('test@example.com')

        pass1_input_box = browser.find_elements_by_css_selector(
            '#create_admin_user > div > form > div > div:nth-child(2) > input[type="password"]'
        )[0]
        pass1_input_box.clear()
        pass1_input_box.send_keys('password')

        pass2_input_box = browser.find_elements_by_css_selector(
            '#create_admin_user > div > form > div > div:nth-child(3) > input[type="password"]'
        )[0]
        pass2_input_box.clear()
        pass2_input_box.send_keys('password')

        submit_button = browser.find_elements_by_css_selector(
            '#create_admin_user > div > form > button'
        )[0]
        submit_button.click()

        sleep(driver_wait_time)
        assert User.objects.count() == 1
        browser.get(live_server + URI)
        assert URI not in browser.current_url
