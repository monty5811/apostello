from collections import namedtuple

import pytest
from rest_framework.authtoken.models import Token
from tests.conftest import twilio_vcr

from apostello import models

StatusCode = namedtuple('StatusCode', 'anon, user, staff')


@pytest.mark.slow
@pytest.mark.parametrize(
    "url,status_code",
    [
        ('/', StatusCode(302, 200, 200)),
        ('/not_approved/', StatusCode(200, 200, 200)),
        ('/group/new/', StatusCode(302, 200, 200)),
        # ('/group/edit/1/', StatusCode(302, 200, 200)),
        ('/group/create_all/', StatusCode(302, 302, 200)),
        ('/recipient/new/', StatusCode(302, 200, 200)),
        # ('/recipient/edit/1/', StatusCode(302, 302, 200)),
        ('/recipient/import/', StatusCode(302, 302, 200)),
        ('/keyword/edit/test/', StatusCode(302, 302, 200)),
        ('/keyword/responses/csv/test/', StatusCode(302, 302, 200)),
        # ('/users/profiles/1/', StatusCode(302, 302, 200)),
        ('/api/v1/users/profiles/', StatusCode(403, 403, 200)),
        # ('/api/v1/users/profiles/1/', StatusCode(403, 403, 200)),
        ('/api/v1/sms/in/', StatusCode(403, 200, 200)),
        ('/api/v1/sms/out/', StatusCode(403, 200, 200)),
        # ('/api/v1/sms/in/1/', StatusCode(403, 200, 200)),
        ('/api/v1/recipients/', StatusCode(403, 200, 200)),
        # ('/api/v1/recipients/1/', StatusCode(403, 200, 200)),
        ('/api/v1/groups/', StatusCode(403, 200, 200)),
        # ('/api/v1/groups/1/', StatusCode(403, 200, 200)),
        ('/api/v1/keywords/', StatusCode(403, 200, 200)),
        ('/api/v1/keywords/test/', StatusCode(403, 200, 200)),
        ('/api/v1/queued/sms/', StatusCode(403, 403, 200)),
        ('/graphs/recent/', StatusCode(302, 200, 200)),
        ('/graphs/contacts/', StatusCode(302, 302, 200)),
        ('/graphs/groups/', StatusCode(302, 302, 200)),
        ('/graphs/keywords/', StatusCode(302, 302, 200)),
        ('/graphs/sms/totals/', StatusCode(302, 302, 200)),
        ('/graphs/sms/in/bycontact/', StatusCode(302, 302, 200)),
        ('/graphs/sms/out/bycontact/', StatusCode(302, 302, 200)),
        ('/config/site/', StatusCode(302, 302, 200)),
        ('/config/responses/', StatusCode(302, 302, 200)),
        ('/config/first_run/', StatusCode(302, 302, 302)),
        ('/api-setup/', StatusCode(302, 302, 200)),
    ]
)
@pytest.mark.django_db
class TestUrls:
    """Test urls and access."""

    def test_not_logged_in(
        self, url, status_code, recipients, groups, smsin, smsout, users
    ):
        """Test not logged in."""
        assert users['c_out'].get(url).status_code == status_code.anon

    def test_in(
        self, url, status_code, recipients, groups, smsin, smsout, keywords,
        users
    ):
        """Test site urls when logged in a normal user"""
        assert users['c_in'].get(url).status_code == status_code.user

    def test_staff(
        self, url, status_code, recipients, groups, smsin, smsout, keywords,
        users
    ):
        """Test logged in as staff"""
        assert users['c_staff'].get(url).status_code == status_code.staff


@pytest.mark.slow
@pytest.mark.django_db
class TestAPITokens:
    """Test Auth Token Access to API."""

    def test_no_access(self, users):
        assert users['c_out'].get('/api/v1/recipients/').status_code == 403

    def test_good_token_staff(self, users, recipients):
        t = Token.objects.create(user=users['staff'])
        r = users['c_out'].get(
            '/api/v1/recipients/',
            **{'HTTP_AUTHORIZATION': 'Token {}'.format(t.key)}
        )
        assert r.status_code == 200
        data = r.json()
        assert data['count'] == len(data['results'])
        assert data['count'] == models.Recipient.objects.count()

    def test_good_token_not_staff(self, users, recipients):
        t = Token.objects.create(user=users['notstaff'])
        r = users['c_out'].get(
            '/api/v1/recipients/',
            **{'HTTP_AUTHORIZATION': 'Token {}'.format(t.key)}
        )
        assert r.status_code == 200
        data = r.json()
        assert data['count'] == len(data['results'])
        assert data['count'] == models.Recipient.objects.filter(
            is_archived=False
        ).count()
