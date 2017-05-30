import pytest
from django.conf import settings
from django.core.exceptions import ValidationError

from apostello.validators import (
    gsm_validator, less_than_sms_char_limit, no_overlap_keyword, not_twilio_num, twilio_reserved, validate_lower,
    validate_starts_with_plus
)
from site_config.models import SiteConfiguration


class TestLower:
    def test_ok(self):
        validate_lower('all_lower_case')

    def test_upper_chars(self):
        with pytest.raises(ValidationError):
            validate_lower('Upper case')


class TestNoTwilioNum():
    def test_ok(self):
        not_twilio_num('+447905639803')

    def test_upper_chars(self):
        with pytest.raises(ValidationError):
            not_twilio_num(settings.TWILIO_FROM_NUM)


class TestNoReserved:
    def test_ok(self):
        twilio_reserved('not_stop')

    def test_match(self):
        for x in ["stop", "stopall", "unsubscribe", "cancel", "end", "quit", "start", "yes", "help", "info", "name"]:
            with pytest.raises(ValidationError):
                twilio_reserved(x)


class TestGsm:
    def test_ok(self):
        gsm_validator('This is an ok message')

    def test_upper_chars(self):
        with pytest.raises(ValidationError):
            gsm_validator('This is not an ok message…')


@pytest.mark.django_db
class TestNoOverlapKeyword:
    def test_new_ok(self, keywords):
        no_overlap_keyword('new_keyword')

    def test_new_bad(self, keywords):
        with pytest.raises(ValidationError):
            no_overlap_keyword('test_keyword')

    def test_new_bad_special(self):
        with pytest.raises(ValidationError):
            no_overlap_keyword('name')

    def test_stop(self):
        with pytest.raises(ValidationError):
            no_overlap_keyword('stop')

    def test_updating(self, keywords):
        no_overlap_keyword('test')


@pytest.mark.django_db
class TestCharLimit:
    def test_no_name_ok(self):
        """Test message ok."""
        s = SiteConfiguration.get_solo()
        less_than_sms_char_limit('t' * (s.sms_char_limit - 1))

    def test_name_ok(self):
        """Test message ok with %name%."""
        less_than_sms_char_limit('test %name%')

    def test_no_name_raises(self):
        """Test raises error with no %name% sub."""
        s = SiteConfiguration.get_solo()
        with pytest.raises(ValidationError):
            less_than_sms_char_limit('t' * (s.sms_char_limit + 1))

    def test_no_name_raises(self):
        """Test shorter limit imposed with %name% present."""
        s = SiteConfiguration.get_solo()
        with pytest.raises(ValidationError):
            less_than_sms_char_limit('t %name%' * (s.sms_char_limit - settings.MAX_NAME_LENGTH + len('%name%')))


class TestStartswithPlus:
    def test_no_plus(self):
        with pytest.raises(ValidationError):
            validate_starts_with_plus('nope')

    def test_plus(self):
        validate_starts_with_plus('+44')
        validate_starts_with_plus('+1')
        validate_starts_with_plus('+test')
        validate_starts_with_plus('+yup')
