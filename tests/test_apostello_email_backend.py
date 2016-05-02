import pytest

from apostello.mail import ApostelloEmailBackend
from site_config.models import SiteConfiguration


@pytest.mark.django_db
def test_apostello_mail_backend():
    """Test email backend pulling from settings and db."""
    # get from Siteconfiguration
    s = SiteConfiguration.get_solo()
    s.get_solo()
    s.email_host = 'smtp.test2.apostello'
    s.save()
    mail_backend = ApostelloEmailBackend()
    assert mail_backend.host == 'smtp.test2.apostello'
    # get from settings
    s.email_host = ''
    s.save()
    mail_backend = ApostelloEmailBackend()
    assert mail_backend.host == 'smtp.test.apostello'
