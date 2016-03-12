from django.conf import settings

from site_config.models import SiteConfiguration


def global_settings(request):
    """Expose TWILIO_FROM_NUM, DEBUG and site config in templates."""
    return {
        'TWILIO_FROM_NUM': settings.TWILIO_FROM_NUM,
        'TWILIO_SENDING_COST': settings.TWILIO_SENDING_COST,
        'DEBUG': settings.DEBUG,
        'CONFIG': SiteConfiguration.get_solo(),
    }


def opbeat_js_settings(request):
    """Expose opbeat frontend credentials"""
    opbeat_vals = [settings.OPBEAT_JS_APP_ID, settings.OPBEAT_JS_ORG_ID]
    if any(val is None for val in opbeat_vals):
        return {}

    return {
        'OPBEAT_JS_APP_ID': settings.OPBEAT_JS_APP_ID,
        'OPBEAT_JS_ORG_ID': settings.OPBEAT_JS_ORG_ID,
    }
