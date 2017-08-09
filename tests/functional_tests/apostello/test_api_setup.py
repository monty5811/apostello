from time import sleep

import pytest
from tests.functional_tests.utils import click_and_wait

URI = '/api-setup/'


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestAPISetup:
    def test_api_setup(self, live_server, browser_in, users, driver_wait_time):
        """Test api-setup form."""
        no_api_token_txt = 'No API Token'
        gen_button_path = '//*[@id="elmContainer"]/div/div[2]/div/div[2]/p/div[2]/button[1]'
        del_button_path = '//*[@id="elmContainer"]/div/div[2]/div/div[2]/p/div[2]/button[2]'
        b = browser_in
        browser_in.get(live_server + URI)
        # show key
        show_button = b.find_elements_by_xpath('//*[@id="elmContainer"]/div/div[2]/div/div[2]/button')[0]
        click_and_wait(show_button, driver_wait_time)
        # delete token that doesn't exist
        del_button = b.find_elements_by_xpath(del_button_path)[0]
        click_and_wait(del_button, driver_wait_time)
        assert no_api_token_txt in b.page_source
        # generate token for first time
        regen_button = b.find_elements_by_xpath(gen_button_path)[0]
        click_and_wait(regen_button, driver_wait_time)
        assert no_api_token_txt not in b.page_source
        # regenerate token
        regen_button = b.find_elements_by_xpath(gen_button_path)[0]
        click_and_wait(regen_button, driver_wait_time)
        assert no_api_token_txt not in b.page_source
        # delete token
        del_button = b.find_elements_by_xpath(del_button_path)[0]
        click_and_wait(del_button, driver_wait_time)
        assert no_api_token_txt in b.page_source
