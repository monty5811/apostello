import os
import json
from datetime import datetime

import pytest
import vcr
from allauth.account.models import EmailAddress
from django.contrib.auth.models import User
from django.test import Client
from django.utils import timezone
from django.utils.timezone import get_current_timezone
from selenium import webdriver

from apostello.models import *


@pytest.fixture(autouse=True)
def short_circuit_q(monkeypatch):
    def new_async(func, *args, **kwargs):
        # pull django_q kwargs out:
        schedule_kwargs = [
            'name', 'hook', 'schedule_type', 'minutes', 'repeats', 'next_run'
        ]
        async_kwargs = [
            'hook', 'group', 'save', 'sync', 'cached', 'iter_count',
            'iter_cached', 'chain', 'broker', 'q_options'
        ]
        for k in schedule_kwargs + async_kwargs:
            kwargs.pop(k, None)
        f = func
        if not callable(func):
            try:
                import importlib
                module, func = f.rsplit('.', 1)
                m = importlib.import_module(module)
                f = getattr(m, func)
            except (ValueError, ImportError, AttributeError) as e:
                result = (e, False)
        result = f(*args, **kwargs)

        return result

    monkeypatch.setattr('django_q.tasks.async.__code__', new_async.__code__)
    monkeypatch.setattr('django_q.tasks.schedule.__code__', new_async.__code__)


@pytest.fixture
def recipients():
    """Create a bunch of recipients for testing."""
    calvin = Recipient.objects.create(
        first_name="John", last_name="Calvin", number='+447927401749'
    )
    house_lamp = Recipient.objects.create(
        first_name="Johannes",
        last_name="Oecolampadius",
        number='+447927401740'
    )
    knox = Recipient.objects.create(
        first_name="John",
        last_name="Knox",
        number='+447928401745',
        is_archived=True
    )
    wesley = Recipient.objects.create(
        first_name="John",
        last_name="Wesley",
        number='+447927401745',
        is_blocking=True
    )
    john_owen = Recipient.objects.create(
        first_name="John", last_name="Owen", number='+15005550004'
    )  # blacklisted magic num
    thomas_chalmers = Recipient.objects.create(
        first_name="Thomas", last_name="Chalmers", number='+15005550009'
    )  # can't recieve
    beza = Recipient.objects.create(
        first_name="Theodore",
        last_name="Beza",
        number='+447927411115',
        do_not_reply=True
    )

    objs = {
        'calvin': calvin,
        'house_lamp': house_lamp,
        'knox': knox,
        'wesley': wesley,
        'john_owen': john_owen,
        'thomas_chalmers': thomas_chalmers,
        'beza': beza,
    }
    return objs


@pytest.mark.usefixtures("recipients")
@pytest.fixture
def groups(recipients):
    """Create some groups with recipients."""
    test_group = RecipientGroup.objects.create(
        name="Test Group",
        description="This is a test group",
    )
    archived_group = RecipientGroup.objects.create(
        name="Archived Group",
        description="This is a test group",
        is_archived=True
    )
    archived_group.save()
    empty_group = RecipientGroup.objects.create(
        name="Empty Group", description="This is an empty group"
    )
    empty_group.save()

    test_group.recipient_set.add(recipients['calvin'])
    test_group.recipient_set.add(recipients['house_lamp'])
    test_group.save()
    objs = {
        'test_group': test_group,
        'empty_group': empty_group,
        'archived_group': archived_group,
    }
    return objs


@pytest.fixture
def smsin():
    """Create some messages."""
    sms1 = SmsInbound.objects.create(
        content='test message',
        time_received=timezone.now(),
        sender_name="John Calvin",
        sender_num="+447927401749",
        matched_keyword="test",
        sid='12345'
    )
    sms1.save()
    sms3 = SmsInbound.objects.create(
        content='test message',
        time_received=timezone.now(),
        sender_name="John Calvin",
        sender_num="+447927401749",
        matched_keyword="test",
        sid='123456789'
    )
    sms3.save()
    sms2 = SmsInbound.objects.create(
        content='archived message',
        time_received=timezone.now(),
        sender_name="John Calvin",
        sender_num="+447927401749",
        matched_keyword="test",
        sid='123456789a',
        is_archived=True
    )
    sms2.save()
    objs = {'sms1': sms1, 'sms2': sms2, 'sms3': sms3}
    return objs


@pytest.fixture
@pytest.mark.usefixtures("recipients", "groups")
def smsout(recipients, groups):
    """Create a single outbound message."""
    smsout = SmsOutbound.objects.create(
        sid='123456',
        content='test',
        sent_by='test',
        recipient_group=groups['test_group'],
        recipient=recipients['calvin']
    )

    objs = {'smsout': smsout}
    return objs


@pytest.fixture
def keywords():
    """Create various keywords for testing different options."""
    # keywords:
    test = Keyword.objects.create(
        keyword="test",
        description="This is an active test keyword with custom response",
        custom_response="Test custom response with %name%",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1970  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
        deactivate_time=timezone.make_aware(
            datetime.strptime('Jun 1 2400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test.save()
    # active with custom response
    test2 = Keyword.objects.create(
        keyword="2test",
        description="This is an active test keyword with no custom response",
        custom_response="",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1970  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
        deactivate_time=timezone.make_aware(
            datetime.strptime('Jun 1 2400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test2.save()
    # active with custom response
    test_expired = Keyword.objects.create(
        keyword="expired_test",
        description="This is an expired test keyword with no custom response",
        custom_response="",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1970  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
        deactivate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1975  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test_expired.save()
    # not yet active with custom response
    test_early = Keyword.objects.create(
        keyword="early_test",
        description="This is a not yet active test keyword "
        "with no custom response",
        custom_response="",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 2400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
        deactivate_time=timezone.make_aware(
            datetime.strptime('Jun 1 2400  1:35PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test_early.save()

    test_no_end = Keyword.objects.create(
        keyword="test_no_end",
        description="This has no end",
        custom_response="Will always reply",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test_no_end.save()
    # test deactivated response
    test_deac_resp_fail = Keyword.objects.create(
        keyword="test_cust_endf",
        description="This has a diff reply",
        custom_response="Hi!",
        deactivated_response="Too slow, Joe!",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )

    test_deac_resp = Keyword.objects.create(
        keyword="test_cust_end",
        description="This has a diff reply",
        custom_response="Just in time!",
        deactivated_response="Too slow, Joe!",
        deactivate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1400  2:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 1400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        )
    )
    test_no_end.save()

    test_early_with_response = Keyword.objects.create(
        keyword="early_test2",
        description="This is a not yet active test keyword"
        "with a custom response",
        too_early_response="This is far too early",
        activate_time=timezone.make_aware(
            datetime.strptime('Jun 1 2400  1:33PM', '%b %d %Y %I:%M%p'),
            get_current_timezone()
        ),
    )
    test_early.save()

    test_do_not_reply = Keyword.objects.create(
        keyword='donotreply',
        disable_all_replies=True,
    )
    test_do_not_reply.save()

    keywords = {
        'test': test,
        'test2': test2,
        'test_expired': test_expired,
        'test_early': test_early,
        'test_no_end': test_no_end,
        'test_deac_resp': test_deac_resp,
        'test_deac_resp_fail': test_deac_resp_fail,
        'test_early_with_response': test_early_with_response,
        'test_do_not_reply': test_do_not_reply,
    }
    return keywords


@pytest.mark.usefixtures("recipients", "keywords")
@pytest.fixture()
def users(recipients, keywords):
    """Create apostello users."""
    user = User.objects.create_user(
        username='test', email='test@example.com', password='top_secret'
    )
    user.profile.save()
    user.is_staff = True
    user.save()
    allauth_email = EmailAddress.objects.create(
        user=user, email=user.email, primary=True, verified=True
    )
    allauth_email.save()
    p = UserProfile.objects.get(user=user)
    p.approved = True
    p.can_send_sms = True
    p.can_see_contact_nums = True
    p.can_import = True
    p.save()

    c = Client()
    c.login(username='test', password='top_secret')

    user2 = User.objects.create_user(
        username='test2', email='test2@example.com', password='top2_secret'
    )
    user2.save()
    user2.profile.save()
    p = UserProfile.objects.get(user=user2)
    p.approved = True
    p.save()
    allauth_email = EmailAddress.objects.create(
        user=user2, email=user2.email, primary=True, verified=True
    )
    allauth_email.save()
    keywords['test'].owners.add(user2)

    user3 = User.objects.create_user(
        username='test3', email='test3@example.com', password='top2_secret'
    )
    user3.save()
    user3.profile.save()
    p = UserProfile.objects.get(user=user3)
    p.approved = True
    p.save()
    user3.profile.approved = True
    user3.profile.save()
    allauth_email = EmailAddress.objects.create(
        user=user3, email=user3.email, primary=True, verified=True
    )
    allauth_email.save()

    c2 = Client()
    c2.login(username='test3', password='top2_secret')
    c_out = Client()

    objs = {
        'staff': user,
        'notstaff': user2,
        'notstaff2': user3,
        'c_staff': c,
        'c_in': c2,
        'c_out': c_out
    }

    return objs


@pytest.fixture(scope='session')
def driver_wait_time():
    """Read web driver implicit wait time from env var. Defaults to 1s.

    If selenium tests are failing, try setting the env var to a higher value,
    e.g. 10.
    """
    return int(os.environ.get('SELENIUM_IMPLICIT_WAIT', 1))


@pytest.fixture(scope='session')
def browser(request, driver_wait_time):
    """Setup selenium browser."""
    driver = webdriver.Firefox()
    driver.implicitly_wait(driver_wait_time)

    def fin():
        try:
            driver.get_screenshot_as_file(
                '/tmp/tmp-selenium-' + request.node.name + '.png'
            )
        except:
            pass
        driver.quit()

    request.addfinalizer(fin)

    return driver


@pytest.mark.usefixtures('users', 'live_server')
@pytest.yield_fixture()
def browser_in(request, live_server, users, driver_wait_time):
    """Setup selenium browser and log in."""
    driver = webdriver.Firefox()
    driver.get(live_server + '/')
    driver.add_cookie(
        {
            u'domain': u'localhost',
            u'name': u'sessionid',
            u'value': users['c_staff'].session.session_key,
            u'path': u'/',
            u'httponly': True,
            u'secure': False
        }
    )
    driver.implicitly_wait(driver_wait_time)
    yield driver
    try:
        driver.get_screenshot_as_file(
            '/tmp/tmp-selenium-' + request.node.name + '.png'
        )
    except:
        pass
    driver.quit()


base_vcr = vcr.VCR(record_mode='none', ignore_localhost=True)
twilio_vcr = base_vcr.use_cassette(
    'tests/fixtures/vcr_cass/twilio.yaml',
    filter_headers=['authorization'],
    match_on=['method', 'scheme', 'host', 'port', 'path', 'query', 'body']
)


def post_json(client, url, data):
    return client.post(
        url,
        json.dumps(data),
        content_type="application/json",
    )
