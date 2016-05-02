from django.core.mail.backends.smtp import EmailBackend


class ApostelloEmailBackend(EmailBackend):
    """Email backend that reads settings from SiteConfiguration model."""

    @staticmethod
    def _db_or_setting(db_val, setting_val):
        """Default to value from settings if db value is None."""
        if db_val:
            return db_val
        return setting_val

    def __init__(self, *args, **kwargs):
        super(ApostelloEmailBackend, self).__init__(*args, **kwargs)
        from site_config.models import SiteConfiguration
        s = SiteConfiguration.get_solo()
        self.host = self._db_or_setting(s.email_host, self.host)
        self.port = self._db_or_setting(s.email_port, self.port)
        self.username = self._db_or_setting(s.email_username, self.username)
        self.password = self._db_or_setting(s.email_password, self.password)
