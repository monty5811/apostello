import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestOthers:
    """Test posting as a user"""

    def test_keyword_responses_archive_all_not_ticked(self, keywords, users):
        users['c_staff'].post(
            '/api/v1/keywords/test/archive_resps/',
            {'tick_to_archive_all_responses': False}
        )

    def test_keyword_responses_archive_all_ticked(
        self, keywords, smsin, users
    ):
        users['c_staff'].post(
            '/api/v1/keywords/test/archive_resps/',
            {'tick_to_archive_all_responses': True}
        )

    def test_no_csv(self, users):
        assert users['c_in'].get(
            '/keyword/responses/csv/not_a_keyword/'
        ).status_code == 404
