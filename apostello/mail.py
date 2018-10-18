from django.core.mail.backends.smtp import EmailBackend


class ApostelloEmailBackend(EmailBackend):
    """Email backend that reads settings from SiteConfiguration model."""

    def __init__(self, *args, **kwargs):
        super(ApostelloEmailBackend, self).__init__(*args, **kwargs)
        from site_config.models import SiteConfiguration

        s = SiteConfiguration.get_solo()
        self.host = s.email_host
        self.port = s.email_port
        self.username = s.email_username
        self.password = s.email_password
