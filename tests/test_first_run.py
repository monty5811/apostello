from django.core import mail
from django.test import Client
from tests.conftest import post_json, twilio_vcr

import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestFirstRun:
    """Test first run experience"""

    def test_first_run_page(self):
        c = Client()
        resp = c.get('/config/first_run/')
        assert resp.status_code == 200

    def test_send_test_email_no_user(self):
        c = Client()
        resp = c.post('/config/send_test_email/')
        assert resp.status_code == 400
        data = resp.json()
        assert data['status'] == 'failed'
        assert 'error' in data

        resp = post_json(
            c, '/config/send_test_email/',
            {'to_': 'test@example.com',
             'body_': 'test message'}
        )
        assert resp.status_code == 200
        assert len(mail.outbox) == 1

    def test_send_test_email_with_user(self, users):
        users['c_in'].post('/config/send_test_email/').status_code == 400

    @twilio_vcr
    def test_send_test_sms_no_user(self, recipients):
        c = Client()
        resp = c.post('/config/send_test_sms/')
        assert resp.status_code == 400
        data = resp.json()
        assert data['status'] == 'failed'
        assert 'error' in data

        resp = post_json(
            c, '/config/send_test_sms/',
            {'to_': str(recipients['calvin'].number),
             'body_': 'test'}
        )
        assert resp.status_code == 200

    def test_send_test_sms_with_user(self, users):
        users['c_in'].post('/config/send_test_sms/').status_code == 400

    def test_create_su(self):
        c = Client()
        resp = c.post('/config/create_admin_user/')
        assert resp.status_code == 400
        data = resp.json()
        assert data['status'] == 'failed'
        assert 'error' in data

        resp = post_json(
            c, '/config/create_admin_user/',
            {'email_': 'test@example.com',
             'pass_': 'testpass'}
        )
        assert resp.status_code == 200

        resp = c.get('/config/first_run/')
        assert resp.status_code == 302
        assert '/' == resp.url

    def test_create_su_no_user(self, users):
        users['c_in'].post('/config/create_admin_user/').status_code == 400
