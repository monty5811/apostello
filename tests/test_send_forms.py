from datetime import datetime, timedelta

import pytest
from tests.conftest import twilio_vcr

from apostello import models, tasks


@pytest.mark.slow
@pytest.mark.django_db
class TestSendingSmsForm:
    """Test the sending of SMS."""

    @twilio_vcr
    def test_send_adhoc_now(self, recipients, users):
        """Test sending a message now."""
        users['c_staff'].post('/api/v2/actions/sms/send/adhoc/', {'content': 'test', 'recipients': ['1']})

    @twilio_vcr
    def test_send_adhoc_later(self, recipients, users):
        """Test sending a message later."""
        num_sms = models.SmsOutbound.objects.count()
        users['c_staff'].post(
            '/api/v2/actions/sms/send/adhoc/', {
                'content': 'test',
                'recipients': ['1'],
                'scheduled_time': '2117-12-01 00:00'
            }
        )
        tasks.send_queued_sms()
        assert models.SmsOutbound.objects.count() == num_sms

    @twilio_vcr
    def test_send_adhoc_soon(self, recipients, users):
        """Test sending a message later."""
        num_sms = models.SmsOutbound.objects.count()
        resp = users['c_staff'].post(
            '/api/v2/actions/sms/send/adhoc/', {
                'content': 'test',
                'recipients': [str(recipients['calvin'].pk)],
                'scheduled_time': datetime.strftime(
                    datetime.now() - timedelta(minutes=5),
                    '%Y-%m-%d %H:%M',
                )
            }
        )
        assert resp.status_code == 201
        tasks.send_queued_sms()
        assert models.SmsOutbound.objects.count() == num_sms + 1

    def test_send_adhoc_error(self, users):
        """Test missing field."""
        resp = users['c_staff'].post('/api/v2/actions/sms/send/adhoc/', {'content': ''})
        assert 'This field is required.' in str(resp.content)

    def test_send_adhoc_not_allowed(self, recipients, users):
        """Test deny sending."""
        resp = users['c_in'].post('/api/v2/actions/sms/send/adhoc/', {'content': 'test', 'recipients': '1'})
        assert "do not have permission" in str(resp.content)
        assert resp.status_code >= 400

    @twilio_vcr
    def test_send_group_now(self, groups, users):
        """Test sending a message now."""
        users['c_staff'].post(
            '/api/v2/actions/sms/send/group/',
            {
                'content': 'test',
                'recipient_group': groups['test_group'].pk
            }
        )

    @twilio_vcr
    def test_send_group_later(self, groups, users):
        """Test sending a message later."""
        users['c_staff'].post(
            '/api/v2/actions/sms/send/group/', {
                'content': 'test',
                'recipient_group': '1',
                'scheduled_time': '2117-12-01 00:00'
            }
        )
        tasks.send_queued_sms()

    def test_send_group_error(self, users):
        """Test missing field."""
        users['c_staff'].post('/api/v2/actions/sms/send/group/', {'content': ''})

    def test_send_group_not_allowed(self, groups, users):
        """Test deny sending."""
        resp = users['c_in'].post('/api/v2/actions/sms/send/group/', {'content': 'test', 'recipient_group': '1'})
        assert "do not have permission" in str(resp.content)
        assert resp.status_code >= 400


@pytest.mark.slow
@pytest.mark.django_db
class TestGroupForm:
    """Test group form usage"""

    def test_new_group(self, users):
        """Test creating a new group."""
        users['c_staff'].post('/api/v2/groups/', {'name': 'test_group', 'description': 'this is a test'})
        test_group = models.RecipientGroup.objects.get(name='test_group')
        assert 'test_group' == str(test_group)

    def test_bring_group_from_archive(self, groups, users):
        """Test creating a group that exists in the archive."""
        users['c_staff'].post('/api/v2/groups/', {'name': 'Archived Group', 'description': 'this is a test'})

    def test_edit_group(self, users):
        """Test editing a group."""
        new_group = models.RecipientGroup.objects.create(name='t1', description='t1')
        new_group.save()
        pk = new_group.pk
        users['c_staff'].post(
            '/api/v2/groups/',
            {
                'name': 'test_group_changed',
                'description': 'this is a test',
                'pk': pk
            }
        )
        assert 'test_group_changed' == str(models.RecipientGroup.objects.get(pk=pk))

    def test_invalid_group_form(self, users):
        """Test submitting an invalid form."""
        resp = users['c_staff'].post('/api/v2/groups/', {'name': '', 'description': 'this is a test'})
        assert 'This field is required.' in str(resp.content)

    def test_create_all_group_form(self, users, recipients):
        """Test the form to create a group composed of all recipients."""
        num_groups = models.RecipientGroup.objects.all().count()
        resp = users['c_staff'].post('/api/v2/actions/group/create_all/', {
            'group_name': 'test all group',
        })
        assert resp.status_code == 201
        assert models.RecipientGroup.objects.all().count() == num_groups + 1
        assert models.RecipientGroup.objects.get(name='test all group').all_recipients.count() == 6

    def test_create_all_group_form_update(self, users, recipients, groups):
        """Test the form to create a group composed of all recipients.
        Test populating an already existing group.
        """
        resp = users['c_staff'].post('/api/v2/actions/group/create_all/', {
            'group_name': 'Empty Group',
        })
        assert resp.status_code == 201
        g = models.RecipientGroup.objects.get(name='Empty Group')
        assert len(g.all_recipients) == 6
