import pytest
from time import sleep

@pytest.mark.django_db
class TestLogin:
    @pytest.mark.parametrize("uri", [
        '/',
    ])
    def test_not_logged_in(self, uri, live_server, browser, users):
        browser.get(live_server + uri)
        assert len(browser.find_elements_by_name('login')) == 1
        assert len(browser.find_elements_by_name('password')) == 1
        assert len(browser.find_elements_by_name('remember')) == 1

    @pytest.mark.parametrize("uri", [
        '/',
    ])
    def test_log_in(self, uri, live_server, browser, users):
        # login
        browser.get(live_server + uri)
        email_button = browser.find_elements_by_xpath('/html/body/div/div/div/button')[0]
        email_button.click()
        sleep(2)
        email_box = browser.find_elements_by_name('login')[0]
        email_box.send_keys(users['staff'].email)
        password_box = browser.find_elements_by_name('password')[0]
        password_box.send_keys('top_secret')
        login_button = browser.find_elements_by_xpath('html/body/div/div/div/div/form/button')[0]
        login_button.click()
        # check we have been redirected
        assert live_server + uri in browser.current_url

        # log out again
        browser.get(live_server + '/accounts/logout')
        logout_confirm = browser.find_elements_by_xpath('html/body/div/div/div/form/button')[0]
        logout_confirm.click()
        assert 'accounts/login' in browser.current_url
