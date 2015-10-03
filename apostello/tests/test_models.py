# -*- coding: utf-8 -*-
import pytest
from django.contrib.auth.models import User
from django.utils import timezone

from ..models import SmsOutbound


@pytest.mark.django_db
class TestSms:
    def test_create_sms(self, recipients, groups):
        sms = SmsOutbound(sid='dummy_sid',
                          content='test',
                          time_sent=timezone.now(),
                          sent_by='test',
                          recipient_group=groups['test_group'],
                          recipient=recipients['calvin'])
        assert 'test' == str(sms)

    def test_reimport_sms(self, smsin):
        smsin['sms1'].reimport()


@pytest.mark.django_db
class TestUserProfile:
    def test_display(self):
        user_staff = User.objects.create_superuser(username='test_staff',
                                                   email='test3@example.com',
                                                   password='top_secret')
        assert "Profile: test_staff" == str(user_staff.profile)
