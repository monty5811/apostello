from time import sleep

import pytest
import vcr
from elvanto.models import ElvantoGroup

my_vcr = vcr.VCR(record_mode='none', )


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.parametrize("uri", ['/elvanto/import/', ])
class TestElvantoImport:
    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml',
        filter_headers=['authorization']
    )
    def test_page_and_submit(self, uri, live_server, browser_in):
        # load groups
        ElvantoGroup.fetch_all_groups()
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # check table is there
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Geneva' in table.text
        assert 'Scotland' in table.text
        assert 'Disabled' in table.text
        # enable a group
        group_button = browser_in.find_elements_by_xpath(
            '//*[@id="elvanto_table"]/table/tbody/tr[1]/td[3]/a')[0]
        group_button.click()
        sleep(3)
        assert 'Syncing' in table.text
        # grab buttons
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        buttons = browser_in.find_elements_by_class_name('fluid')
        fetch_button = buttons[0]
        # fetch groups
        wrench.click()
        fetch_button.click()
        try:
            alert = browser_in.switch_to_alert()
            alert.accept()
        except Exception:
            pass
        # pull groups
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        wrench = browser_in.find_elements_by_class_name('wrench')[0]
        wrench.click()
        buttons = browser_in.find_elements_by_class_name('fluid')
        pull_button = buttons[1]
        pull_button.click()
