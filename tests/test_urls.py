# -*- coding: utf-8 -*-
import pytest

from apostello import models
from elvanto import models as emodels
from site_config import models as smodels


@pytest.mark.slow
@pytest.mark.parametrize(
    "url,status_code", [
        ('/', 302),
        ('/send/adhoc/', 302),
        ('/send/group/', 302),
        ('/group/all/', 302),
        ('/group/new/', 302),
        ('/group/edit/1/', 302),
        ('/recipient/all/', 302),
        ('/recipient/new/', 302),
        ('/recipient/edit/1/', 302),
        ('/keyword/all/', 302),
        ('/keyword/new/', 302),
        ('/keyword/edit/1/', 302),
        ('/keyword/responses/1/', 302),
        ('/keyword/responses/1/archive/', 302),
        ('/keyword/responses/csv/1/', 302),
        ('/api/v1/sms/in/', 403),
        ('/api/v1/sms/out/', 403),
        ('/api/v1/sms/in/recpient/1/', 403),
        ('/api/v1/sms/in/keyword/1/', 403),
        ('/api/v1/sms/in/keyword/1/archive/', 403),
        ('/api/v1/sms/in/1', 403),
        ('/api/v1/recipients/', 403),
        ('/api/v1/recipients/1', 403),
        ('/api/v1/groups/', 403),
        ('/api/v1/groups/1', 403),
        ('/api/v1/keywords/', 403),
        ('/api/v1/keywords/1', 403),
        ('/graphs/recent/', 200),
    ]
)
@pytest.mark.django_db
class TestNotLoggedIn:
    """Test site urls when not logged in."""

    def test_not_logged_in(self, url, status_code, recipients, groups, smsin,
                           smsout, users):
        assert users['c_out'].get(url).status_code == status_code


@pytest.mark.slow
@pytest.mark.parametrize(
    "url,status_code", [
        ('/', 200),
        ('/send/adhoc/', 200),
        ('/send/group/', 200),
        ('/group/all/', 200),
        ('/group/new/', 200),
        ('/group/edit/1/', 200),
        ('/recipient/all/', 200),
        ('/recipient/new/', 200),
        ('/recipient/edit/1/', 200),
        ('/keyword/all/', 200),
        ('/keyword/new/', 200),
        ('/keyword/edit/1/', 200),
        ('/keyword/responses/1/', 200),
        ('/keyword/responses/1/archive/', 200),
        ('/keyword/responses/csv/1/', 200),
        ('/recipient/import/', 200),
        ('/elvanto/import/', 200),
        ('/keyword/responses/wall/1/', 200),
        ('/keyword/responses/curate_wall/1/', 200),
        ('/incoming/wall/', 200),
        ('/incoming/curate_wall/', 200),
        ('/api/v1/sms/in/', 200),
        ('/api/v1/sms/out/', 200),
        ('/api/v1/sms/in/recpient/1/', 200),
        ('/api/v1/sms/in/keyword/1/', 200),
        ('/api/v1/sms/in/keyword/1/archive/', 200),
        ('/api/v1/sms/in/1', 200),
        ('/api/v1/recipients/', 200),
        ('/api/v1/recipients/1', 200),
        ('/api/v1/groups/', 200),
        ('/api/v1/groups/1', 200),
        ('/api/v1/keywords/', 200),
        ('/api/v1/keywords/1', 200),
        ('/api/v1/sms/live_wall/in/', 200),
    ]
)
@pytest.mark.django_db
class TestStaff:
    """Test site urls when logged in as staff"""

    def test_staff(self, url, status_code, recipients, groups, smsin, smsout,
                   keywords, users):
        assert users['c_staff'].get(url).status_code == status_code


@pytest.mark.slow
@pytest.mark.parametrize(
    "url,status_code", [
        ('/', 200),
        ('/send/adhoc/', 302),
        ('/send/group/', 302),
        ('/group/all/', 200),
        ('/group/new/', 200),
        ('/group/edit/1/', 200),
        ('/recipient/all/', 200),
        ('/recipient/new/', 200),
        ('/recipient/edit/1/', 302),
        ('/keyword/all/', 200),
        ('/keyword/new/', 200),
        ('/keyword/edit/1/', 302),
        ('/keyword/responses/1/', 302),
        ('/keyword/responses/1/archive/', 302),
        ('/keyword/responses/csv/1/', 302),
        ('/recipient/import/', 302),
        ('/elvanto/import/', 302),
        ('/keyword/responses/wall/1/', 302),
        ('/keyword/responses/curate_wall/1/', 302),
        ('/incoming/wall/', 200),
        ('/incoming/curate_wall/', 200),
        ('/incoming/', 200),
        ('/api/v1/sms/in/', 200),
        ('/api/v1/sms/out/', 200),
        ('/api/v1/sms/in/recpient/1/', 200),
        ('/api/v1/sms/in/keyword/1/', 403),
        ('/api/v1/sms/in/keyword/1/archive/', 403),
        ('/api/v1/sms/in/keyword/2/', 200),
        ('/api/v1/sms/in/keyword/2/archive/', 200),
        ('/api/v1/sms/in/1', 200),
        ('/api/v1/recipients/', 200),
        ('/api/v1/recipients/1', 200),
        ('/api/v1/groups/', 200),
        ('/api/v1/groups/1', 200),
        ('/api/v1/keywords/', 200),
        ('/api/v1/keywords/1', 200),
        ('/api/v1/sms/live_wall/in/', 200),
    ]
)
@pytest.mark.django_db
class TestNotStaff:
    """Test site urls when logged in a normal user"""

    def test_in(self, url, status_code, recipients, groups, smsin, smsout,
                keywords, users):
        assert users['c_in'].get(url).status_code == status_code


@pytest.mark.slow
@pytest.mark.django_db
class TestOthers:
    """Test posting as a user"""

    def test_api_posts(self, recipients, groups, smsin, smsout, keywords,
                       users):
        for endpoint in ['sms']:
            for param in ['reingest', 'deal_with', 'archive', 'display_on_wall'
                          ]:
                for value in ['true', 'false']:
                    users['c_staff'].post('/api/v1/' + endpoint + '/in/1',
                                          {param: value})

    def test_api_elvanto_posts(self, users):
        # turn on
        config = smodels.SiteConfiguration.get_solo()
        config.sync_elvanto = True
        config.save()
        r = users['c_staff'].post('/api/v1/elvanto/group_fetch/', {})
        users['c_staff'].post('/api/v1/elvanto/group_pull/', {})
        r = users['c_staff'].get('/api/v1/elvanto/groups/')
        assert len(r.data) == 5
        r = users['c_staff'].get('/api/v1/elvanto/group/1')
        assert r.data['name'] == 'Geneva'
        assert r.data['pk'] == 1
        r = users['c_staff'].post('/api/v1/elvanto/group/1', {'sync': 'false'})
        assert r.data['sync']
        assert emodels.ElvantoGroup.objects.get(pk=1).sync
        r = users['c_staff'].post('/api/v1/elvanto/group/1', {'sync': 'true'})
        assert r.data['sync'] is False
        assert emodels.ElvantoGroup.objects.get(pk=1).sync is False

    def test_send_adhoc_now(self, recipients, users):
        users['c_staff'].post('/send/adhoc/', {'content': 'test',
                                               'recipients': ['1']})

    def test_send_adhoc_later(self, recipients, users):
        users['c_staff'].post(
            '/send/adhoc/', {
                'content': 'test',
                'recipients': ['1'],
                'scheduled_time': '2117-12-01 00:00'
            }
        )

    def test_send_adhoc_error(self, users):
        resp = users['c_staff'].post('/send/adhoc/', {'content': ''})
        assert 'This field is required.' in str(resp.content)

    def test_send_group_now(self, groups, users):
        users['c_staff'].post('/send/group/', {'content': 'test',
                                               'recipient_group': '1'})

    def test_send_group_later(self, groups, users):
        users['c_staff'].post(
            '/send/group/', {
                'content': 'test',
                'recipient_group': '1',
                'scheduled_time': '2117-12-01 00:00'
            }
        )

    def test_send_group_error(self, users):
        users['c_staff'].post('/send/group/', {'content': ''})

    def test_new_group(self, users):
        users['c_staff'].post('/group/new/', {'name': 'test_group',
                                              'description': 'this is a test'})
        test_group = models.RecipientGroup.objects.get(name='test_group')
        assert 'test_group' == str(test_group)

    def test_bring_group_from_archive(self, groups, users):
        users['c_staff'].post('/group/new/', {'name': 'Archived Group',
                                              'description': 'this is a test'})

    def test_edit_group(self, users):
        new_group = models.RecipientGroup.objects.create(name='t1',
                                                         description='t1')
        new_group.save()
        pk = new_group.pk
        users['c_staff'].post(
            new_group.get_absolute_url, {
                'name': 'test_group_changed',
                'description': 'this is a test'
            }
        )
        assert 'test_group_changed' == str(models.RecipientGroup.objects.get(
            pk=pk))

    def test_invalid_group_form(self, users):
        resp = users['c_staff'].post('/group/new/',
                                     {'name': '',
                                      'description': 'this is a test'})
        assert 'This field is required.' in str(resp.content)

    def test_keyword_responses_404(self, keywords, users):
        assert users['c_staff'].post(
            '/keyword/responses/51234/').status_code == 404

    def test_keyword_responses_archive_all_not_ticked(self, keywords, users):
        users['c_staff'].post('/keyword/responses/1/',
                              {'tick_to_archive_all_responses': False})

    def test_keyword_responses_archive_all_ticked(self, keywords, smsin,
                                                  users):
        users['c_staff'].post(
            '/keyword/responses/{}/'.format(keywords['test'].pk),
            {'tick_to_archive_all_responses': True}
        )

    def test_csv_import_blank(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ''})

    def test_csv_import_bad_data(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ',,,\n,,,'})

    def test_csv_import_good_data(self, users):
        users['c_staff'].post(
            '/recipient/import/', {
                'csv_data':
                'test,person,+447902533904,\ntest,person,+447902537994'
            }
        )

    def test_elvanto_import(self, users):
        users['c_staff'].post('/elvanto/import/', {})

    def test_no_csv(self, users):
        assert users['c_in'].get(
            '/keyword/responses/csv/500/').status_code == 404

    def test_keyword_access_check(self, keywords, users):
        keywords['test'].owners.add(users['staff'])
        keywords['test'].save()
        assert users['c_staff'].get(keywords[
            'test'].get_responses_url).status_code == 200
        assert users['c_in'].get(keywords[
            'test'].get_responses_url).status_code == 302

    def test_check_perms_not_staff(self, users, keywords, recipients):
        assert users['c_in'].get('/incoming/').status_code == 200
        assert users['c_in'].get('/elvanto/import/').status_code == 302
        assert users['c_in'].get(recipients[
            'calvin'].get_absolute_url).status_code == 302
