from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, click_and_wait, load_page

from apostello import models

NEW_URI = "/group/new/"


def send_form(b, wt):
    send_button = b.find_element_by_id("formSubmitButton")
    click_and_wait(send_button, wt)
    return b


def add_recipient(b, wt):
    return b


def add_group_name(b, wt):
    name_box = b.find_element_by_name("name")
    name_box.clear()
    name_box.send_keys("test_new_group")
    sleep(wt)
    return b


def add_description(b, wt):
    desc_box = b.find_element_by_name("description")
    desc_box.clear()
    desc_box.send_keys("test_new_group")
    sleep(wt)
    return b


@pytest.mark.slow
@pytest.mark.selenium
class TestGroupForm:
    def test_create_new_group(self, live_server, browser_in, users, driver_wait_time):
        """Test good form submission."""
        assert 0 == models.RecipientGroup.objects.count()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert 1 == models.RecipientGroup.objects.count()
            assert "/group/all/" in b.current_url
            assert "test_new_group" in b.page_source

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_edit_group(self, live_server, browser_in, users, driver_wait_time, groups):
        assert len(groups) == models.RecipientGroup.objects.count()
        b = load_page(browser_in, driver_wait_time, live_server + "/group/edit/{}/".format(groups["test_group"].pk))
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert len(groups) == models.RecipientGroup.objects.count()
            assert "/group/all/" in b.current_url
            assert "test_new_group" in b.page_source
            assert groups["test_group"].description not in b.page_source
            assert "group members" not in b.page_source.lower()

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_create_existing_group(self, live_server, browser_in, users, driver_wait_time):
        self.test_create_new_group(live_server, browser_in, users, driver_wait_time)
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)
        b = add_description(b, driver_wait_time)
        b = send_form(b, driver_wait_time)

        def _test():
            assert 1 == models.RecipientGroup.objects.count()
            assert "/group/new/" in b.current_url
            assert "recipient group with this name of group already exists" in b.page_source.lower()
            assert "group members" not in b.page_source.lower()

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_create_existing_archived_group(self, live_server, browser_in, users, driver_wait_time):
        self.test_create_new_group(live_server, browser_in, users, driver_wait_time)
        for g in models.RecipientGroup.objects.all():
            g.is_archived = True
            g.save()
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        b = add_group_name(b, driver_wait_time)

        def _test():
            assert "/group/new/" in b.current_url
            assert "There is already a Group that with that name in the archive".lower() in b.page_source.lower()
            assert "Or you can restore the group here:".lower() in b.page_source.lower()
            assert "group members" not in b.page_source.lower()

        assert_with_timeout(_test, 10 * driver_wait_time)

    def test_group_membership_buttons(self, live_server, browser_in, recipients, groups, driver_wait_time):
        """Test editing group membership."""
        non_member_id = "nonmembers_item"
        member_id = "members_item"
        grp = groups["empty_group"]
        browser_in.get(live_server + "/group/edit/" + str(grp.pk) + "/")
        # check all recipient are displayed
        cards = browser_in.find_elements_by_id(non_member_id)
        assert len(cards) == models.Recipient.objects.filter(is_archived=False).count()
        # move all recipients into membership
        while len(cards) > 0:
            click_and_wait(cards[0], driver_wait_time)
            cards = browser_in.find_elements_by_id(non_member_id)
        assert grp.all_recipients.count() == models.Recipient.objects.filter(is_archived=False).count()
        # remove them again:
        cards = browser_in.find_elements_by_id(member_id)
        while len(cards) > 0:
            click_and_wait(cards[0], driver_wait_time)
            cards = browser_in.find_elements_by_id(member_id)
        sleep(driver_wait_time)
        assert grp.all_recipients.count() == 0

    def test_create_all_group_form(self, live_server, browser_in, recipients, groups, driver_wait_time):
        """Test form to create group with all contacts."""
        b = load_page(browser_in, driver_wait_time, live_server + "/group/create_all/")

        name_box = b.find_element_by_name("group_name")
        name_box.clear()
        name_box.send_keys("Test All Group")
        sleep(driver_wait_time)

        send_form(b, driver_wait_time)
        assert "/group/all/" in b.current_url
        assert models.RecipientGroup.objects.get(name="Test All Group").all_recipients_not_in_group.count() == 0
