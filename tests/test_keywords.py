import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestOthers:
    """Test posting as a user"""

    def test_keyword_responses_404(self, keywords, users):
        assert users['c_staff'].post(
            '/keyword/responses/51234/'
        ).status_code == 404

    def test_keyword_responses_archive_all_not_ticked(self, keywords, users):
        users['c_staff'].post(
            '/keyword/responses/1/', {'tick_to_archive_all_responses': False}
        )

    def test_keyword_responses_archive_all_ticked(
        self, keywords, smsin, users
    ):
        users['c_staff'].post(
            '/keyword/responses/{}/'.format(keywords['test'].pk),
            {'tick_to_archive_all_responses': True}
        )

    def test_no_csv(self, users):
        assert users['c_in'].get(
            '/keyword/responses/csv/500/'
        ).status_code == 404

    def test_keyword_access_check(self, keywords, users):
        keywords['test'].owners.add(users['staff'])
        keywords['test'].save()
        assert users['c_staff'].get(
            keywords[
                'test'
            ].get_responses_url
        ).status_code == 200
        assert users['c_in'].get(
            keywords[
                'test'
            ].get_responses_url
        ).status_code == 302
