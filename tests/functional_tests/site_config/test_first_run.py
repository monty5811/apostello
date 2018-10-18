from time import sleep

import pytest
from django.contrib.auth.models import User
from tests.functional_tests.utils import assert_with_timeout

URI = "/config/first_run/"


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestFirstRun:
    def test_page_content(self, live_server, browser):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        assert "This page will help you" in browser.page_source

    def test_user_form(self, live_server, browser, driver_wait_time):
        browser.get(live_server + URI)
        assert URI in browser.current_url
        sleep(driver_wait_time)
        email_input_box = browser.find_elements_by_id("admin_email")[0]
        email_input_box.clear()
        email_input_box.send_keys("test@example.com")

        pass1_input_box = browser.find_elements_by_id("admin_pass1")[0]
        pass1_input_box.clear()
        pass1_input_box.send_keys("password")

        pass2_input_box = browser.find_elements_by_id("admin_pass2")[0]
        pass2_input_box.clear()
        pass2_input_box.send_keys("password")

        submit_button = browser.find_elements_by_id("create_admin_button")[0]
        submit_button.click()

        def _test():
            assert User.objects.count() == 1

        assert_with_timeout(_test, 5 * driver_wait_time)

        browser.get(live_server + URI)
        assert URI not in browser.current_url
