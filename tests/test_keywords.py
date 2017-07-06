import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestKeywords:
    def test_keyword_responses_archive_all_not_ticked(self, keywords, users):
        users['c_staff'].post('/api/v2/keywords/test/archive_resps/', {'tick_to_archive_all_responses': False})

    def test_keyword_responses_archive_all_ticked(self, keywords, smsin, users):
        users['c_staff'].post('/api/v2/keywords/test/archive_resps/', {'tick_to_archive_all_responses': True})

    def test_no_csv(self, users):
        assert users['c_in'].get('/keyword/responses/csv/not_a_keyword/').status_code == 404

    def test_sms_filtering(self, keywords, smsin, users):
        """Check SMS that have matched a keyword are not shown to users when
        they are blocked from that keyword."""
        staff_data = users['c_staff'].get('/api/v2/sms/in/').json()
        not_staff_data = users['c_in'].get('/api/v2/sms/in/').json()
        assert staff_data['count'] > not_staff_data['count']
        excluded_k = keywords['test'].keyword
        non_staff_matches = [x.matched_keyword for x in not_staff_data['results']]
        assert excluded_k not in non_staff_matches
