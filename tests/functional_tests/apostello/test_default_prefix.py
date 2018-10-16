from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, load_page

URI = '/recipient/new/'


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestDefaultPrefix:
    def test_default_prefix(self, live_server, browser_in, users, driver_wait_time):
        """Test prefix shows on form."""
        from site_config.models import SiteConfiguration
        config = SiteConfiguration.get_solo()
        config.default_number_prefix = '+45'
        config.save()
        b = load_page(browser_in, driver_wait_time, live_server + URI)

        # test is there
        def _test():
            num_input = b.find_element_by_id('id_number')
            assert num_input.get_attribute("value") == '+45'

        assert_with_timeout(_test, 10 * driver_wait_time)

        config.default_number_prefix = ''
        config.save()
        b = load_page(browser_in, driver_wait_time, live_server + URI)

        # test is not there
        def _test():
            num_input = b.find_element_by_id('id_number')
            assert num_input.get_attribute("value") != '+45'
