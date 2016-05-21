import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestButtonPosts:
    """Test api end points behind buttons"""

    def test_api_posts(
        self, recipients, groups, smsin, smsout, keywords, users
    ):
        for endpoint in ['sms']:
            for param in [
                'reingest', 'dealt_with', 'archived', 'display_on_wall'
            ]:
                for value in ['true', 'false']:
                    users['c_staff'].post(
                        '/api/v1/' + endpoint + '/in/1', {param: value}
                    )
