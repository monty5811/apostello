from time import sleep

import pytest
from tests.functional_tests.utils import assert_with_timeout, click_and_wait, load_page
from tests.conftest import twilio_vcr

from apostello import models

NEW_URI = '/config/twilio/delete/'


@pytest.mark.slow
@pytest.mark.selenium
class TestContactForm:
    @twilio_vcr
    def test_twilio_delete_flow(self, live_server, browser_in, users, smsin, smsout, driver_wait_time):
        """Test good form submission."""
        b = load_page(browser_in, driver_wait_time, live_server + NEW_URI)
        n_in = models.SmsInbound.objects.count()
        n_out = models.SmsOutbound.objects.count()
        sleep(driver_wait_time * 3)
        click_and_wait(b.find_element_by_id(f'incoming_sms{smsin["sms1"].pk}'), driver_wait_time)
        click_and_wait(b.find_element_by_id(f'outgoing_sms{smsout["smsout"].pk}'), driver_wait_time)
        click_and_wait(b.find_element_by_id('deleteButton'), driver_wait_time)
        click_and_wait(b.find_element_by_id('confirmButton'), driver_wait_time)
        b.find_element_by_id('confirmDeleteInput').send_keys('I understand this cannot be undone')
        click_and_wait(b.find_element_by_id('finalConfirmButton'), driver_wait_time)

        def _test():
            assert ('Messages successfully queued for deletion.' in b.page_source)
            assert n_in - 1 == models.SmsInbound.objects.count()
            assert n_out - 1 == models.SmsOutbound.objects.count()

        assert_with_timeout(_test, 10 * driver_wait_time)
