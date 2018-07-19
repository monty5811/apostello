from time import sleep

import pytest
from tests.functional_tests.utils import load_page

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
        assert 'value="+45"' in b.page_source
        config.default_number_prefix = ''
        config.save()
        b = load_page(browser_in, driver_wait_time, live_server + URI)
        assert 'value="+45"' not in b.page_source
