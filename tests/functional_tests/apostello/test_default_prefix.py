from time import sleep

import pytest

URI = '/recipient/new/'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestDefaultPrefix:
    def test_default_prefix(
        self, live_server, browser_in, users, driver_wait_time
    ):
        """Test prefix shows on form."""
        from site_config.models import SiteConfiguration
        config = SiteConfiguration.get_solo()
        config.default_number_prefix = '+45'
        config.save()
        b = load_page(browser_in, driver_wait_time, live_server + URI)
        assert '+45' in b.page_source
        config.default_number_prefix = ''
        config.save()
        b = load_page(browser_in, driver_wait_time, live_server + URI)
        assert '+45' not in b.page_source
