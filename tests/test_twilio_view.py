# -*- coding: utf-8 -*-
import sys

import pytest
from django.conf import settings
from django.test import RequestFactory
from twilio.util import RequestValidator

from apostello.models import *
from apostello.views import *

if sys.version_info[0] == 3:
    from urllib.parse import urljoin
else:
    from urlparse import urljoin


class TwilioRequestFactory(RequestFactory):
    def __init__(self, token, **defaults):
        super(TwilioRequestFactory, self).__init__(**defaults)
        self.base_url = 'http://testserver/'
        self.twilio_auth_token = token

    def _compute_signature(self, path, params):
        return RequestValidator(self.twilio_auth_token).compute_signature(urljoin(self.base_url, path), params=params)

    def get(self, path, data=None, **extra):
        if data is None:
            data = {}
        if 'HTTP_X_TWILIO_SIGNATURE' not in extra:
            extra.update({'HTTP_X_TWILIO_SIGNATURE': self._compute_signature(path, params=data)})
        return super(TwilioRequestFactory, self).get(path, data, **extra)

    def post(self, path, data=None, content_type=None, **extra):
        if data is None:
            data = {}
        if 'HTTP_X_TWILIO_SIGNATURE' not in extra:
            extra.update({'HTTP_X_TWILIO_SIGNATURE': self._compute_signature(path, params=data)})
        if content_type is None:
            return super(TwilioRequestFactory, self).post(path, data, **extra)
        else:
            return super(TwilioRequestFactory, self).post(path, data, content_type, **extra)


uri = '/sms/'


def test_request_data():
    return {
        u'ToCountry': u'GB',
        u'ToState': u'Prudhoe',
        u'SmsMessageSid': u'SMaddde4b15454abd70fa726b9fab1b6ed',
        u'NumMedia': u'0',
        u'ToCity': u'---',
        u'FromZip': u'---',
        u'SmsSid': u'SMaddde4b15454abd70fa726b9fab1b6ed',
        u'FromState': u'---',
        u'SmsStatus': u'received',
        u'FromCity': u'---',
        u'Body': u'test',
        u'FromCountry': u'GB',
        u'To': u'+441661312031',
        u'ToZip': u'---',
        u'MessageSid': u'SMaddde4b15454abd70fa726b9fab1b6ed',
        u'AccountSid': u'AC37da8c50f65fe69a83a25579e578d4cd',
        u'From': u'+447902537906',
        u'ApiVersion': u'2010-04-01',
    }


@pytest.mark.slow
@pytest.mark.parametrize(
    "msg,reply", [
        (u"Test", u"Test custom response"),
        (u"2testing", u"your message has been received"),
        (u"name John", u"Something went wrong"),
        (u"name John Calvin", u"John"),
        (u"start", u"Thanks for signing up"),
    ]
)
@pytest.mark.django_db
class TestTwilioView:
    def test_not_logged_in(self, msg, reply, keywords):
        factory = TwilioRequestFactory(token=settings.TWILIO_AUTH_TOKEN)
        data = test_request_data()
        data['Body'] = msg
        request = factory.post(uri, data=data)
        resp = sms(request)
        assert reply in str(resp.content)


@pytest.mark.slow
@pytest.mark.parametrize(
    "msg,reply", [
        (u"Test", u"Test custom response"),
        (u"2testing", u"your message has been received"),
        (u"name John", u"Something went wrong"),
        (u"name John Calvin", u"John"),
        (u"start", u"Thanks for signing up"),
    ]
)
@pytest.mark.django_db
class TestTwilioViewNoReplies:
    def test_not_logged_in(self, msg, reply, keywords):
        factory = TwilioRequestFactory(token=settings.TWILIO_AUTH_TOKEN)
        data = test_request_data()
        data['Body'] = msg
        request = factory.post(uri, data=data)
        # turn off responses
        from site_config.models import SiteConfiguration
        config = SiteConfiguration.get_solo()
        config.disable_all_replies = True
        config.save()
        # run test
        resp = sms(request)
        assert reply not in str(resp.content)
