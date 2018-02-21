from allauth.socialaccount.models import SocialApp
from django.conf import settings

from site_config.models import SiteConfiguration


def global_settings(request):
    """Expose TWILIO_FROM_NUM, DEBUG and site config in templates."""
    return {
        'CONFIG': SiteConfiguration.get_solo(),
        'DISPLAY_GOOGLE_LOGIN': SocialApp.objects.filter(provider='google').count(),
        'ROLLBAR_ACCESS_TOKEN_CLIENT': settings.ROLLBAR_ACCESS_TOKEN_CLIENT,
    }
