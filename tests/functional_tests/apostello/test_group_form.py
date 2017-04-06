from time import sleep

import pytest

from apostello import models
from tests.functional_tests.utils import assert_with_timeout, click_and_wait

NEW_URI = '/group/new/'


def load_page(b, wt, url):
    b.get(url)
    assert url in b.current_url
    sleep(wt)
    return b


def send_form(b, wt):
    send_button = b.find_elements_by_class_name('primary')[0]
    click_and_wait(send_button, wt)
    return b


def add_recipient(b, wt):
    return b


def add_group_name(b, wt):
    name_box = b.find_element_by_name('name')
    name_box.clear()
    name_box.send_keys('test_new_group')
    sleep(wt)
    return b


def add_description(b, wt):
    desc_box = b.find_element_by_name('description')
    desc_box.clear()
    desc_box.send_keys('test_new_group')
    sleep(wt)
    return b


@pytest.mark.slow
@pytest.mark.selenium
class TestGroupForm:
    def test_create_new_group(
        self, live_server, browser_in, users, driver_wait_time
    ):
        """Test good form submission."""
        assert 0 == models.RecipientGroup.objects.count()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert 1 == models.RecipientGroup.objects.count()
            assert '/group/all/' in b.current_url
            assert 'test_new_group' in b.page_source
        assert_with_timeout(_test, 10*driver_wait_time)

    def test_edit_group(
        self, live_server, browser_in, users, driver_wait_time, groups
    ):
        assert len(groups) == models.RecipientGroup.objects.count()
        b = load_page(
            browser_in, driver_wait_time,
            live_server + '/group/edit/{}/'.format(groups['test_group'].pk)
        )
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)
        def _test():
            assert len(groups) == models.RecipientGroup.objects.count()
            assert '/group/all/' in b.current_url
            assert 'test_new_group' in b.page_source
            assert groups['test_group'].description not in b.page_source
            assert 'group members' not in b.page_source.lower()
        assert_with_timeout(_test, 10*driver_wait_time)

    def test_create_existing_group(
        self, live_server, browser_in, users, driver_wait_time
    ):
        self.test_create_new_group(
            live_server, browser_in, users, driver_wait_time
        )
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)
        def _test():
            assert 1 == models.RecipientGroup.objects.count()
            assert '/group/new/' in b.current_url
            assert 'recipient group with this name of group already exists' in b.page_source.lower(
            )
            assert 'group members' not in b.page_source.lower()
        assert_with_timeout(_test, 10*driver_wait_time)

    def test_create_existing_archived_group(
        self, live_server, browser_in, users, driver_wait_time
    ):
        self.test_create_new_group(
            live_server, browser_in, users, driver_wait_time
        )
        grp = models.RecipientGroup.objects.get(name='test_new_group')
        grp.archive()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)
        def _test():
            assert 1 == models.RecipientGroup.objects.count()
            assert '/group/edit/' in b.current_url
            assert 'Update' in b.page_source
            assert 'restore' in b.page_source
            assert 'group members' in b.page_source.lower()
        assert_with_timeout(_test, 10*driver_wait_time)

    def test_group_membership_buttons(
        self, live_server, browser_in, recipients, groups, driver_wait_time
    ):
        """Test editing group membership."""
        non_member_xpath = '//*[@id="elmContainer"]/div/div/div/div[1]/div/div[2]/div/div'
        member_xpath = '//*[@id="elmContainer"]/div/div/div/div[2]/div/div[2]/div/div'
        grp = groups['empty_group']
        browser_in.get(live_server + grp.get_absolute_url)
        # check all recipient are displayed
        cards = browser_in.find_elements_by_xpath(non_member_xpath)
        assert len(cards) == models.Recipient.objects.filter(
            is_archived=False
        ).count()
        # move all recipients into membership
        while len(cards) > 0:
            click_and_wait(cards[0], driver_wait_time)
            cards = browser_in.find_elements_by_xpath(non_member_xpath)
        assert grp.all_recipients.count() == models.Recipient.objects.filter(
            is_archived=False
        ).count()
        # remove them again:
        cards = browser_in.find_elements_by_xpath(member_xpath)
        while len(cards) > 0:
            click_and_wait(cards[0], driver_wait_time)
            cards = browser_in.find_elements_by_xpath(member_xpath)
        sleep(driver_wait_time)
        assert grp.all_recipients.count() == 0
