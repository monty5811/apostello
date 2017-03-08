import pytest


@pytest.mark.django_db
@pytest.mark.slow
@pytest.mark.selenium
@pytest.mark.parametrize("uri", ['/config/responses/', ])
class TestDefaultResponses:
    def test_display_form(self, uri, live_server, browser_in):
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        ids = [
            'id_keyword_no_match',
            'id_default_no_keyword_auto_reply',
            'id_default_no_keyword_not_live',
            'id_start_reply',
            'id_auto_name_request',
            'id_name_update_reply',
            'id_name_failure_reply',
        ]
        for id_ in ids:
            assert len(browser_in.find_elements_by_id(id_)) == 1

    def test_edit_form(self, uri, live_server, browser_in):
        browser_in.get(live_server + uri)
        assert uri in browser_in.current_url
        input_box = browser_in.find_elements_by_id('id_start_reply')[0]
        input_box.clear()
        input_box.send_keys('Thank you for signing up :-)')
        input_box.submit()

        from site_config.models import DefaultResponses
        resps = DefaultResponses.get_solo()
        assert 'Thank you for signing up' in resps.start_reply
