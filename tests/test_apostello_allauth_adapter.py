import pytest

from apostello.account import ApostelloAccountAdapter
from site_config.models import SiteConfiguration


@pytest.mark.django_db
def test_get_email():
    """Test pulling email from settings and SiteConfiguration."""
    s = SiteConfiguration.get_solo()
    a = ApostelloAccountAdapter()
    # test from db
    s.email_from = 'test2@apostello.ninja'
    s.save()
    assert a.get_from_email() == 'test2@apostello.ninja'
    # test from settings
    s.email_from = ''
    s.save()
    assert a.get_from_email() == 'test@apostello.ninja'
