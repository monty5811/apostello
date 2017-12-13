from time import sleep

import pytest
from django.contrib.auth.models import User
from flaky import flaky
from tests.conftest import MAX_RUNS
from tests.functional_tests.utils import assert_with_timeout


@flaky(max_runs=MAX_RUNS)
@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestUserProfiles:
    def test_table_page_and_buttons(self, live_server, browser_in, users, driver_wait_time):
        """Test the table of users."""
        uri = '/users/profiles/'
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url

        # check table is there
        def _test1():
            tables = browser_in.find_elements_by_class_name('table-bordered')
            assert len(tables) == 1
            table = tables[0]
            assert 'Approved' in table.text
            assert 'Incoming' in table.text
            assert 'test@example.com' in table.text

        assert_with_timeout(_test1, 10 * driver_wait_time)
        # toggle approved button:
        user_staff_approved_button_attr = f'[data-test-id=approved-{users["staff"].profile.pk}]'
        toggle = browser_in.find_element_by_css_selector(user_staff_approved_button_attr)
        assert toggle.text == '✔'
        toggle.click()

        def _test2():
            assert toggle.text == '✖'
            assert not users['staff'].profile.approved

        assert_with_timeout(_test2, 10 * driver_wait_time)

    def test_user_profile_form(self, live_server, browser_in, users, driver_wait_time):
        """Test an individual user profile form."""
        uri = '/users/profiles/' + str(users['staff'].pk)
        assert users['staff'].profile.can_archive
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        sleep(driver_wait_time)
        # toggle
        toggle_button = browser_in.find_element_by_id('id_can_archive')
        assert toggle_button.is_selected()
        toggle_button.click()
        sleep(driver_wait_time)
        assert not toggle_button.is_selected()
        # submit
        save_button = browser_in.find_element_by_id('formSubmitButton')
        save_button.click()

        def _test():
            assert uri not in browser_in.current_url
            u = User.objects.get(pk=users['staff'].pk)
            assert u.profile.can_archive is False

        assert_with_timeout(_test, 10 * driver_wait_time)
