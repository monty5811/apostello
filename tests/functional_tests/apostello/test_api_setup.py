from time import sleep

from tests.functional_tests.utils import assert_with_timeout, click_and_wait

import pytest

URI = '/api-setup/'


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestAPISetup:
    def test_api_setup(self, live_server, browser_in, users, driver_wait_time):
        """Test api-setup form."""
        no_api_token_txt = 'No API Token'
        b = browser_in
        browser_in.get(live_server + URI)
        # show key
        show_button = b.find_element_by_id('showKeyButton')
        click_and_wait(show_button, driver_wait_time)

        # delete token that doesn't exist
        def _test():
            b.find_element_by_id('delKeyButton').click()
            assert no_api_token_txt in b.page_source

        assert_with_timeout(_test, driver_wait_time)

        # generate token for first time
        def _test():
            b.find_element_by_id('genKeyButton').click()
            assert no_api_token_txt not in b.page_source

        assert_with_timeout(_test, driver_wait_time)

        # regenerate token
        def _test():
            b.find_element_by_id('genKeyButton').click()
            assert no_api_token_txt not in b.page_source

        assert_with_timeout(_test, driver_wait_time)

        # delete token
        def _test():
            b.find_element_by_id('delKeyButton').click()
            assert no_api_token_txt in b.page_source

        assert_with_timeout(_test, driver_wait_time)
