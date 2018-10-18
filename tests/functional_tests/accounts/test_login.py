from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, click_and_wait

URI = "/"


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestLogin:
    def test_not_logged_in(self, live_server, browser, users):
        browser.get(live_server + URI)
        assert len(browser.find_elements_by_name("login")) == 1
        assert len(browser.find_elements_by_name("password")) == 1
        assert len(browser.find_elements_by_name("remember")) == 1

    def test_log_in(self, live_server, browser, driver_wait_time, users):
        # login
        browser.get(live_server + URI)
        email_box = browser.find_elements_by_name("login")[0]
        email_box.send_keys(users["staff"].email)
        password_box = browser.find_elements_by_name("password")[0]
        password_box.send_keys("top_secret")
        login_button = browser.find_element_by_id("login_button")
        login_button.click()

        # check we have been redirected
        def _test():
            assert "accounts" not in browser.current_url

        assert_with_timeout(_test, 5 * driver_wait_time)

        # log out again
        browser.get(live_server + "/accounts/logout/")
        logout_confirm = browser.find_element_by_id("logout_button")
        logout_confirm.click()

        def _test():
            assert "accounts/login" in browser.current_url

        assert_with_timeout(_test, 10 * driver_wait_time)
