# -*- coding: utf-8 -*-
import pytest

from api.views import *

from ..models import *
from ..views import *


@pytest.mark.django_db
class TestStaff:
    def test_not_logged_in(self, recipients, groups, smsin, smsout, users):
        resp = users['c_out'].get('/')
        assert resp.url.endswith("/login/google-oauth2?next=/")
        assert resp.status_code == 302

        assert users['c_out'].get('/send/adhoc/').status_code == 302
        assert users['c_out'].get('/send/group/').status_code == 302
        assert users['c_out'].get('/group/all/').status_code == 302
        assert users['c_out'].get('/group/new/').status_code == 302
        assert users['c_out'].get('/group/edit/1/').status_code == 302
        assert users['c_out'].get('/recipient/all/').status_code == 302
        assert users['c_out'].get('/recipient/new/').status_code == 302
        assert users['c_out'].get('/recipient/edit/1/').status_code == 302
        assert users['c_out'].get('/keyword/all/').status_code == 302
        assert users['c_out'].get('/keyword/new/').status_code == 302
        assert users['c_out'].get('/keyword/edit/1/').status_code == 302
        assert users['c_out'].get('/keyword/responses/1/').status_code == 302
        assert users['c_out'].get('/keyword/responses/1/archive/').status_code == 302
        assert users['c_out'].get('/keyword/responses/csv/1/').status_code == 302

        assert users['c_out'].get('/api/v1/sms/in/').status_code == 403
        assert users['c_out'].get('/api/v1/sms/out/').status_code == 403
        assert users['c_out'].get('/api/v1/sms/in/recpient/1/').status_code == 403
        assert users['c_out'].get('/api/v1/sms/in/keyword/1/').status_code == 403
        assert users['c_out'].get('/api/v1/sms/in/keyword/1/archive/').status_code == 403
        assert users['c_out'].get('/api/v1/sms/in/1').status_code == 403
        assert users['c_out'].get('/api/v1/recipients/').status_code == 403
        assert users['c_out'].get('/api/v1/recipients/1').status_code == 403
        assert users['c_out'].get('/api/v1/groups/').status_code == 403
        assert users['c_out'].get('/api/v1/groups/1').status_code == 403
        assert users['c_out'].get('/api/v1/keywords/').status_code == 403
        assert users['c_out'].get('/api/v1/keywords/1').status_code == 403

    def test_staff(self, recipients, groups, smsin, smsout, keywords, users):
        assert users['c_staff'].get('/').status_code == 200
        assert users['c_staff'].get('/send/adhoc/').status_code == 200
        assert users['c_staff'].get('/send/group/').status_code == 200
        assert users['c_staff'].get('/group/all/').status_code == 200
        assert users['c_staff'].get('/group/new/').status_code == 200
        assert users['c_staff'].get('/group/edit/1/').status_code == 200
        assert users['c_staff'].get('/recipient/all/').status_code == 200
        assert users['c_staff'].get('/recipient/new/').status_code == 200
        assert users['c_staff'].get('/recipient/edit/1/').status_code == 200
        assert users['c_staff'].get('/keyword/all/').status_code == 200
        assert users['c_staff'].get('/keyword/new/').status_code == 200
        assert users['c_staff'].get('/keyword/edit/1/').status_code == 200
        assert users['c_staff'].get('/keyword/responses/1/').status_code == 200
        assert users['c_staff'].get('/keyword/responses/1/archive/').status_code == 200
        assert users['c_staff'].get('/keyword/responses/csv/1/').status_code == 200
        assert users['c_staff'].get('/recipient/import/').status_code == 200
        assert users['c_staff'].get('/elvanto/import/').status_code == 200
        assert users['c_staff'].get('/keyword/responses/wall/1/').status_code == 200
        assert users['c_staff'].get('/keyword/responses/curate_wall/1/').status_code == 200
        assert users['c_staff'].get('/incoming/wall/').status_code == 200
        assert users['c_staff'].get('/incoming/curate_wall/').status_code == 200

        assert users['c_staff'].get('/api/v1/sms/in/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/out/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/in/recpient/1/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/in/keyword/1/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/in/keyword/1/archive/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/in/1').status_code == 200
        assert users['c_staff'].get('/api/v1/recipients/').status_code == 200
        assert users['c_staff'].get('/api/v1/recipients/1').status_code == 200
        assert users['c_staff'].get('/api/v1/groups/').status_code == 200
        assert users['c_staff'].get('/api/v1/groups/1').status_code == 200
        assert users['c_staff'].get('/api/v1/keywords/').status_code == 200
        assert users['c_staff'].get('/api/v1/keywords/1').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/live_wall/in/').status_code == 200
        assert users['c_staff'].get('/api/v1/sms/live_wall/in/keyword/1/').status_code == 200

    def test_in(self, recipients, groups, smsin, smsout, keywords, users):
        assert users['c_in'].get('/').status_code == 200
        assert users['c_in'].get('/send/adhoc/').status_code == 302
        assert users['c_in'].get('/send/group/').status_code == 302
        assert users['c_in'].get('/group/all/').status_code == 200
        assert users['c_in'].get('/group/new/').status_code == 200
        assert users['c_in'].get('/group/edit/1/').status_code == 200
        assert users['c_in'].get('/recipient/all/').status_code == 200
        assert users['c_in'].get('/recipient/new/').status_code == 200
        assert users['c_in'].get('/recipient/edit/1/').status_code == 302
        assert users['c_in'].get('/keyword/all/').status_code == 200
        assert users['c_in'].get('/keyword/new/').status_code == 200
        assert users['c_in'].get('/keyword/edit/1/').status_code == 302
        assert users['c_in'].get('/keyword/responses/1/').status_code == 302
        assert users['c_in'].get('/keyword/responses/1/archive/').status_code == 302
        assert users['c_in'].get('/keyword/responses/csv/1/').status_code == 302
        assert users['c_in'].get('/recipient/import/').status_code == 302
        assert users['c_in'].get('/elvanto/import/').status_code == 302
        assert users['c_in'].get('/keyword/responses/wall/1/').status_code == 302
        assert users['c_in'].get('/keyword/responses/curate_wall/1/').status_code == 302
        assert users['c_in'].get('/incoming/wall/').status_code == 200
        assert users['c_in'].get('/incoming/curate_wall/').status_code == 200
        assert users['c_in'].get('/incoming/').status_code == 200

        assert users['c_in'].get('/api/v1/sms/in/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/out/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/in/recpient/1/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/in/keyword/1/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/in/keyword/1/archive/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/in/1').status_code == 200
        assert users['c_in'].get('/api/v1/recipients/').status_code == 200
        assert users['c_in'].get('/api/v1/recipients/1').status_code == 200
        assert users['c_in'].get('/api/v1/groups/').status_code == 200
        assert users['c_in'].get('/api/v1/groups/1').status_code == 200
        assert users['c_in'].get('/api/v1/keywords/').status_code == 200
        assert users['c_in'].get('/api/v1/keywords/1').status_code == 200
        assert users['c_in'].get('/api/v1/sms/live_wall/in/').status_code == 200
        assert users['c_in'].get('/api/v1/sms/live_wall/in/keyword/1/').status_code == 200

    def test_api_posts(self, recipients, groups, smsin, smsout, keywords, users):
        for endpoint in ['sms']:
            for param in ['reingest', 'deal_with', 'archive', 'display_on_wall']:
                for value in ['true', 'false']:
                    users['c_staff'].post('/api/v1/' + endpoint + '/in/1', {param: value})

    def test_send_adhoc_now(self, recipients, users):
        users['c_staff'].post('/send/adhoc/', {'content': 'test', 'recipients': ['1']})

    def test_send_adhoc_later(self, recipients, users):
        users['c_staff'].post('/send/adhoc/', {'content': 'test',
                              'recipients': ['1'],
                              'scheduled_time': '2117-12-01 00:00'})

    def test_send_adhoc_error(self, users):
        resp = users['c_staff'].post('/send/adhoc/', {'content': ''})
        assert 'This field is required.' in str(resp.content)

    def test_send_group_now(self, groups, users):
        users['c_staff'].post('/send/group/', {'content': 'test', 'recipient_group': '1'})

    def test_send_group_later(self, groups, users):
        users['c_staff'].post('/send/group/', {'content': 'test',
                                               'recipient_group': '1',
                                               'scheduled_time': '2117-12-01 00:00'})

    def test_send_group_error(self, users):
        users['c_staff'].post('/send/group/', {'content': ''})

    def test_new_group(self, users):
        users['c_staff'].post('/group/new/', {'name': 'test_group',
                                              'description': 'this is a test'})
        test_group = RecipientGroup.objects.get(name='test_group')
        assert 'test_group' == str(test_group)

    def test_bring_group_from_archive(self, groups, users):
        users['c_staff'].post('/group/new/',
                              {'name': 'Archived Group',
                               'description': 'this is a test'})

    def test_edit_group(self, users):
        new_group = RecipientGroup.objects.create(name='t1',
                                                  description='t1')
        new_group.save()
        pk = new_group.pk
        users['c_staff'].post(new_group.get_absolute_url(),
                              {'name': 'test_group_changed',
                               'description': 'this is a test'})
        assert 'test_group_changed' == str(RecipientGroup.objects.get(pk=pk))

    def test_invalid_group_form(self, users):
        resp = users['c_staff'].post('/group/new/', {'name': '',
                                     'description': 'this is a test'})
        assert 'This field is required.' in str(resp.content)

    def test_keyword_responses_404(self, keywords, users):
        assert users['c_staff'].post('/keyword/responses/51234/').status_code == 404

    def test_keyword_responses_archive_all_not_ticked(self, keywords, users):
        users['c_staff'].post('/keyword/responses/1/', {'tick_to_archive_all_responses': False})

    def test_keyword_responses_archive_all_ticked(self, keywords, smsin, users):
        users['c_staff'].post('/keyword/responses/{}/'.format(keywords['test'].pk), {'tick_to_archive_all_responses': True})

    def test_csv_import_blank(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ''})

    def test_csv_import_bad_data(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ',,,\n,,,'})

    def test_csv_import_good_data(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': 'test,person,+447902533904,\ntest,person,+447902537994'})

    def test_elvanto_import_not_valid(self, users):
        users['c_staff'].post('/elvanto/import/', {})

    def test_elvanto_import_valid(self, users):
        from apostello.elvanto import grab_elvanto_groups
        group_id = grab_elvanto_groups()[2][0]
        users['c_staff'].post('/elvanto/import/', {'elvanto_groups': [group_id]})

    def test_utlities(self, users):
        users['c_staff'].post('/utilities/', {'function_to_run': ''})
        users['c_staff'].post('/utilities/', {'function_to_run': 'update_sms_names'})
        users['c_staff'].post('/utilities/', {'function_to_run': 'import_incoming_sms'})
        users['c_staff'].post('/utilities/', {'function_to_run': 'import_outgoing_sms'})

    def test_keyword_access_check(self, keywords, users):
        assert users['c_in'].get('/keyword/responses/csv/500/').status_code == 404
        keywords['test'].owners.add(users['staff'])
        keywords['test'].save()
        assert users['c_staff'].get(keywords['test'].get_responses_url).status_code == 200
        assert users['c_in'].get(keywords['test'].get_responses_url).status_code == 302

    def test_check_perms_not_staff(self, users):
        assert users['c_in'].get('/incoming/').status_code == 200

    # def test_locked_keyword_api(self, users):
    #     kw_l = Keyword.objects.create(keyword="locked",
    #                                   description="This is an active test keyword with custom response",
    #                                   custom_response="Test custom response with %name%",
    #                                   activate_time=timezone.make_aware(datetime.strptime('Jun 1 1970  1:33PM', '%b %d %Y %I:%M%p'),
    #                                                                     get_current_timezone()),
    #                                   deactivate_time=timezone.make_aware(datetime.strptime('Jun 1 2400  1:33PM', '%b %d %Y %I:%M%p'),
    #                                                                       get_current_timezone()))
    #     kw_l.save()
    #     user = User.objects.create_user(username='test_again',
    #                                     email='testagain@example.com',
    #                                     password='top_secret')
    #     user.profile
    #     user.save()
