from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, click_and_wait

from apostello import models

NEW_URI = '/recipient/import/'
DEFAULT_NUM = '+447777777771'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


def add_csv_data(b, wt, text):
    field = b.find_element_by_name('csv_data')
    field.clear()
    field.send_keys(text)
    sleep(wt)
    return b


def send_form(b, wt):
    button = b.find_element_by_id('formSubmitButton')
    click_and_wait(button, wt)
    return b


@pytest.mark.slow
@pytest.mark.selenium
def test_csv_import_ok(live_server, browser_in, recipients, users, driver_wait_time):
    assert len(recipients) == models.Recipient.objects.count()
    b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
    b = add_csv_data(b, driver_wait_time, 'csv,import,' + DEFAULT_NUM)
    b = send_form(b, driver_wait_time)

    def _test():
        assert len(recipients) + 1 == models.Recipient.objects.count()
        assert '/recipient/import/' not in b.current_url

    assert_with_timeout(_test, 10 * driver_wait_time)

@pytest.mark.slow
@pytest.mark.sel
def test_csv_import_bad(live_server, browser_in, recipients, users, driver_wait_time):
    assert len(recipients) == models.Recipient.objects.count()
    b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
    b = add_csv_data(b, driver_wait_time, 'csv,')
    b = send_form(b, driver_wait_time)

    def _test():
        assert len(recipients) == models.Recipient.objects.count()
        assert '/recipient/import/' in b.current_url
        assert 'Uh oh,' in b.page_source

    assert_with_timeout(_test, 10 * driver_wait_time)
