from time import sleep

import pytest


@pytest.mark.django_db(transaction=True)
@pytest.mark.slow
@pytest.mark.selenium
class TestGroupComposer:
    """Test the group composer."""

    def test_elmContainer_display(
        self, live_server, browser_in, recipients, groups, driver_wait_time
    ):
        uri = '/group/composer'
        # load page
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        sleep(driver_wait_time)
        # check help text is there
        header = browser_in.find_elements_by_xpath(
            '//*[@id="elmContainer"]/div/div[1]/div/h2'
        )
        assert len(header) == 1
        # check input box is there
        input_ = browser_in.find_elements_by_xpath(
            '//*[@id="elmContainer"]/div/div[2]/div/div/input'
        )
        assert len(input_) == 1
        # check reload button is there
        reload_ = browser_in.find_elements_by_xpath(
            '//*[@id="elmContainer"]/div/div[3]/div[1]/div/h4/div/i'
        )
        assert len(reload_) == 1
        # check correct number of groups appear
        groups_ = browser_in.find_elements_by_xpath(
            '//*[@id="elmContainer"]/div/div[3]/div[1]/div/div/div'
        )
        num_groups = 0
        for k, v in groups.items():
            if not v.is_archived:
                num_groups += 1
        assert len(groups_) == num_groups
