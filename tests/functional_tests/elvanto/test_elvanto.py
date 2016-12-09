from time import sleep

import pytest
import vcr
from elvanto.models import ElvantoGroup
from tests.functional_tests.utils import check_and_close_biu

my_vcr = vcr.VCR(record_mode='none', ignore_localhost=True)


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
@pytest.mark.parametrize("uri", ['/elvanto/import/', ])
class TestElvantoImport:
    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_page_load(self, uri, live_server, browser_in, driver_wait_time):
        """Test page loads and table renders."""
        # load groups
        ElvantoGroup.fetch_all_groups()
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # check table is there
        sleep(driver_wait_time)
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Geneva' in table.text
        assert 'Scotland' in table.text
        assert 'Disabled' in table.text

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_pull_groups(self, uri, live_server, browser_in, driver_wait_time):
        """Test toggle syncing of a group and then pull groups."""
        # load groups
        ElvantoGroup.fetch_all_groups()
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # enable a group
        sleep(driver_wait_time)
        group_button = browser_in.find_elements_by_xpath(
            '//*[@id="react_table"]/table/tbody/tr[1]/td[3]/a'
        )[0]
        group_button.click()
        sleep(driver_wait_time)
        table = browser_in.find_elements_by_class_name('table')[0]
        assert 'Syncing' in table.text
        # pull groups
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        sleep(driver_wait_time)
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        wrench.click()
        buttons = browser_in.find_elements_by_class_name('fluid')
        pull_button = buttons[1]
        pull_button.click()
        sleep(driver_wait_time)
        fab_dim = browser_in.find_elements_by_id('fabDim')[0]
        fab_dim.click()
        sleep(driver_wait_time)
        check_and_close_biu(browser_in, driver_wait_time)

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_fetch_groups(
        self, uri, live_server, browser_in, driver_wait_time
    ):
        "Test fetch group button." ""
        # fetch groups
        browser_in.get(live_server + uri)
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        wrench.click()
        buttons = browser_in.find_elements_by_class_name('fluid')
        fetch_button = buttons[0]
        fetch_button.click()
        sleep(driver_wait_time)
        fab_dim = browser_in.find_elements_by_id('fabDim')[0]
        fab_dim.click()
        sleep(driver_wait_time)
        check_and_close_biu(browser_in, driver_wait_time)
