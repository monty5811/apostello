from urllib.parse import urljoin

import pytest
from django.conf import settings
from django.core import mail
from django.test import RequestFactory
from tests.conftest import twilio_vcr
from twilio.request_validator import RequestValidator

from apostello import tasks
from apostello.models import *
from apostello.views import *
from site_config.models import SiteConfiguration


def get_token():
    config = SiteConfiguration.get_solo()
    return config.twilio_auth_token


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
        u'From': u'+447927401749',
        u'ApiVersion': u'2010-04-01',
    }


def test_request_data_blocked():
    data = test_request_data()
    data['From'] = u'+447927401745'
    return data

def test_request_data_unknown():
    data = test_request_data()
    data['From'] = u'+447097565645'
    return data


_msg_and_replies = [
        (u"Test", u"Test custom response with John"),
        (u"2testing", u"your message has been received"),
        (u"name John", u"Something went wrong"),
        (u"name John Calvin\nthis is a really really long surname now", u"John"),
        (u"name John Calvin", u"John"),
        (u"start", u"Thanks for signing up"),
    ]

msg_and_replies = []
for msg, reply in _msg_and_replies:
    msg_and_replies.append((msg, reply))
    for c in """!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ """:
        msg_and_replies.append((c + msg, reply))


@pytest.mark.slow
@pytest.mark.parametrize("msg,reply", msg_and_replies)
@pytest.mark.django_db
@twilio_vcr
def test_twilio_view(msg, reply, keywords, recipients):
    # make sure replies are on:
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    config.disable_all_replies = False
    config.save()
    factory = TwilioRequestFactory(token=get_token())
    data = test_request_data()
    data['Body'] = msg
    request = factory.post(uri, data=data)
    resp = sms(request)
    assert reply in str(resp.content)


@pytest.mark.slow
@pytest.mark.django_db
@twilio_vcr
def test_twilio_view_unknown_contact(keywords, recipients):
    # make sure replies are on:
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    config.disable_all_replies = False
    config.save()
    factory = TwilioRequestFactory(token=get_token())
    data = test_request_data_unknown()
    data['Body'] = u'Test'
    request = factory.post(uri, data=data)
    resp = sms(request)
    assert 'Unknown' not in str(resp.content)
    assert 'Thanks new person!' in str(resp.content)


@pytest.mark.slow
@pytest.mark.django_db
@twilio_vcr
def test_twilio_view_blocking_contact(keywords, recipients):
    # make sure replies are on:
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    config.disable_all_replies = False
    config.save()
    factory = TwilioRequestFactory(token=get_token())
    data = test_request_data_blocked()
    data['Body'] = u'Test'
    request = factory.post(uri, data=data)
    resp = sms(request)
    assert '<Response />' in str(resp.content)


@pytest.mark.slow
@pytest.mark.django_db
@twilio_vcr
def test_twilio_view_ask_for_name(keywords):
    # make sure replies are on:
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    config.disable_all_replies = False
    config.office_email = 'test@example.com'
    config.save()
    factory = TwilioRequestFactory(token=get_token())
    data = test_request_data()
    data['Body'] = u'Test'
    request = factory.post(uri, data=data)
    resp = sms(request)
    assert 'Unknown' not in str(resp.content)
    assert 'Thanks new person!' in str(resp.content)
    assert len(mail.outbox) == 1
    assert 'asked for their name' in mail.outbox[0].body


@pytest.mark.slow
@pytest.mark.parametrize("msg,reply", msg_and_replies)
@pytest.mark.django_db
@twilio_vcr
def test_twilio_view_no_replies(msg, reply, keywords):
    factory = TwilioRequestFactory(token=get_token())
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
