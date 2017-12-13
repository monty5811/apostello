from allauth.account.adapter import DefaultAccountAdapter
from django.conf import settings


class ApostelloAccountAdapter(DefaultAccountAdapter):
    """Custom adapter for django-allauth.

    Overrides `get_from_email` to load from db.
    """

    def get_from_email(self):
        """Override to use SiteConfiguration."""
        from site_config.models import SiteConfiguration
        s = SiteConfiguration.get_solo()
        return s.email_from
