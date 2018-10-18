from time import sleep

import pytest
from django.conf import settings


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
class TestAccessDenied:
    def test_keyword_edit(self, live_server, browser_in_not_staff, users, keywords, driver_wait_time):
        """Check we are redirected from the edit page and correct info
        is displayed to user."""
        uri = "/keyword/edit/{}/".format(keywords["test"])
        # check we cannot edit the keyword
        b = browser_in_not_staff
        b.get(live_server + uri)
        sleep(driver_wait_time)
        assert uri in b.current_url  # not redirected (spa)
        assert "Uh, oh, you don't have access" in b.page_source

    def test_keyword_responses(self, live_server, browser_in_not_staff, users, keywords, driver_wait_time):
        """Check we are not able to see the responses page and correct info
        is displayed to user."""
        uri = "/keyword/responses/{}/".format(keywords["test"])
        # check we cannot edit the keyword
        b = browser_in_not_staff
        b.get(live_server + uri)
        sleep(driver_wait_time)
        assert uri in b.current_url  # not redirected (spa)
        assert "Uh, oh, you don't have access" in b.page_source
