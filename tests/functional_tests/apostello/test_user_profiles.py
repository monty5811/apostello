from time import sleep

import pytest


@pytest.mark.django_db
@pytest.mark.slow
class TestUserProfiles:
    def test_table_page_and_buttons(
        self, live_server, browser_in, users, driver_wait_time
    ):
        """Test the table of users."""
        uri = '/users/profiles/'
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        # check table is there
        sleep(driver_wait_time)
        tables = browser_in.find_elements_by_class_name('table')
        assert len(tables) == 1
        table = tables[0]
        assert 'Approved' in table.text
        assert 'Incoming' in table.text
        assert 'test@example.com' in table.text
        # toggle a permission
        toggle_button = browser_in.find_elements_by_class_name('minus')[0]
        toggle_button.click()
        assert users['staff'].profile.approved

    def test_user_profile_form(self, live_server, browser_in, users,
                               driver_wait_time):
        """Test an individual user profile form."""
        uri = users['staff'].profile.get_absolute_url()
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        sleep(driver_wait_time)
        # toggle
        toggle_button = browser_in.find_elements_by_class_name('checkbox')[0]
        toggle_button.click()
        # submit
        save_button = browser_in.find_elements_by_class_name('primary')[0]
        save_button.click()
        assert uri not in browser_in.current_url
