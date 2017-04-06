import pytest
from tests.conftest import post_json


@pytest.mark.slow
@pytest.mark.django_db
class TestButtonPosts:
    """Test api end points behind buttons"""

    def test_api_posts(
        self, recipients, groups, smsin, smsout, keywords, users
    ):
        url = '/api/v1/smsin/{}/'.format(smsin['sms1'].pk)
        for param in ['reingest', 'dealt_with', 'archived', 'display_on_wall']:
            for value in [True, False]:
                post_json(users['c_staff'], url, {param: value})

    def test_group_members_api(self, recipients, groups, users):
        # setup
        grp = groups['empty_group']
        url = '/api/v1/groups/{}/'.format(grp.pk)
        assert grp.all_recipients.count() == 0
        initial_not_in_group = grp.all_recipients_not_in_group.count()
        # add calvin to group
        post_json(
            users['c_staff'], url,
            {'member': False,
             'contactPk': recipients['calvin'].pk}
        )
        assert grp.all_recipients.count() == 1
        assert initial_not_in_group - 1 == grp.all_recipients_not_in_group.count(
        )
        # remove calvin from group
        post_json(
            users['c_staff'], url,
            {'member': True,
             'contactPk': recipients['calvin'].pk}
        )
        assert grp.all_recipients.count() == 0
        assert initial_not_in_group == grp.all_recipients_not_in_group.count()
