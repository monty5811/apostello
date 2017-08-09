from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, click_and_wait

from apostello import models

NEW_URI = '/keyword/new/'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


def send_form(b, wt):
    send_button = b.find_elements_by_class_name('primary')[0]
    click_and_wait(send_button, wt)
    return b


def update_field(b, wt, name, val):
    field = b.find_element_by_name(name)
    field.clear()
    field.send_keys(val)
    sleep(wt)
    return b


def add_keyword(b, wt, k='form'):
    return update_field(b, wt, 'keyword', k)


def add_desc(b, wt, desc='form test'):
    return update_field(b, wt, 'description', desc)


def add_custom_response(b, wt, resp='test custom response'):
    return update_field(b, wt, 'custom_response', resp)


def add_deac_response(b, wt, resp='test deactivated response'):
    return update_field(b, wt, 'deactivated_response', resp)


def add_too_early_response(b, wt, resp='test too early response'):
    return update_field(b, wt, 'too_early_response', resp)


def add_activate_time(b, wt, t='1900-01-01 15:03'):
    return update_field(b, wt, 'activate_time', t)


def add_deactivate_time(b, wt, t='2100-01-01 15:03'):
    return update_field(b, wt, 'deactivate_time', t)


def add_linked_groups(b, wt):
    # TODO implement and test
    return b


def add_owner(b, wt):
    user = b.find_element_by_xpath(
        '//*[@id="elmContainer"]/div/div[2]/div/div[2]/form/div[6]/div/div/div[2]/div[2]/div[3]/div[1]'
        )
    user.click()
    return b


def add_subscriber(b, wt):
    user = b.find_element_by_xpath(
        '//*[@id="elmContainer"]/div/div[2]/div/div[2]/form/div[6]/div/div/div[3]/div[2]/div[3]/div[1]'
        )
    user.click()
    return b


@pytest.mark.slow
@pytest.mark.selenium
class TestKeywordForm:
    def test_create_new_keyword(self, live_server, browser_in, keywords, groups, users, driver_wait_time):
        """Test good form submission."""
        assert len(keywords) == models.Keyword.objects.count()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_keyword(b, driver_wait_time)
        b = add_desc(b, driver_wait_time)
        b = add_custom_response(b, driver_wait_time)
        b = add_deac_response(b, driver_wait_time)
        b = add_too_early_response(b, driver_wait_time)
        b = add_activate_time(b, driver_wait_time)
        b = add_deactivate_time(b, driver_wait_time)
        b = add_linked_groups(b, driver_wait_time)
        b = add_owner(b, driver_wait_time)
        b = add_subscriber(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert len(keywords) + 1 == models.Keyword.objects.count()
            assert '/keyword/all/' in b.current_url
            k = models.Keyword.objects.get(keyword='form')
            assert k.is_live
            assert k.subscribed_to_digest.count() == 1
            assert k.owners.count() == 1

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_edit_keyword(self, live_server, browser_in, keywords, users, driver_wait_time):
        assert len(keywords) == models.Keyword.objects.count()
        b = load_page(browser_in, driver_wait_time, live_server + '/keyword/edit/test/')
        b = add_desc(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert len(keywords) == models.Keyword.objects.count()
            assert '/keyword/all/' in b.current_url
            assert 'form' in b.page_source
            assert models.Keyword.objects.get(keyword='test').keyword == 'test'

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_create_existing_keyword(self, live_server, browser_in, keywords, users, driver_wait_time):
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_keyword(b, driver_wait_time, k='test')
        b = send_form(b, driver_wait_time)

        def _test():
            assert '/keyword/new/' in b.current_url
            assert 'keyword with this keyword already exists' in b.page_source.lower()
            assert len(keywords) == models.Keyword.objects.count()

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_create_existing_archived_keyword(self, live_server, browser_in, keywords, users, driver_wait_time):
        for k in models.Keyword.objects.all():
            k.is_archived = True
            k.save()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_keyword(b, driver_wait_time, k='test')

        def _test():
            assert '/keyword/new/' in b.current_url
            assert 'there is already a keyword that with that name in the archive'.lower() in b.page_source.lower()
            assert 'Or you can restore the keyword here:'.lower() in b.page_source.lower()

        assert_with_timeout(_test, 10 * driver_wait_time)
