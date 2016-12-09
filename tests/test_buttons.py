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
                        '/api/v1/' + endpoint + '/in/1',
                        {param: value}
                    )

    def test_group_members_api(self, recipients, groups, users):
        # setup
        grp = groups['empty_group']
        url = grp.get_api_url
        assert grp.all_recipients.count() == 0
        initial_not_in_group = grp.all_recipients_not_in_group.count()
        # add calvin to group
        users['c_staff'].post(
            url,
            {'member': 'false',
             'contactPk': recipients['calvin'].pk}
        )
        assert grp.all_recipients.count() == 1
        assert initial_not_in_group - 1 == grp.all_recipients_not_in_group.count(
        )
        # remove calvin from group
        users['c_staff'].post(
            url,
            {'member': 'true',
             'contactPk': recipients['calvin'].pk}
        )
        assert grp.all_recipients.count() == 0
        assert initial_not_in_group == grp.all_recipients_not_in_group.count()
