from functools import wraps

from django.conf import settings
from django.http import (HttpRequest, HttpResponse, HttpResponseForbidden, HttpResponseNotAllowed)
from django.views.decorators.csrf import csrf_exempt
from twilio.request_validator import RequestValidator
from twilio.rest import Client

twilio_client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)


def twilio_view(f):
    """
    Copied from: https://github.com/rdegges/django-twilio/blob/master/django_twilio/decorators.py


    This decorator provides several helpful shortcuts for writing Twilio views.

        - It ensures that only requests from Twilio are passed through. This
          helps protect you from forged requests.

        - It ensures your view is exempt from CSRF checks via Django's
          @csrf_exempt decorator. This is necessary for any view that accepts
          POST requests from outside the local domain (eg: Twilio's servers).

        - It allows your view to (optionally) return TwiML to pass back to
          Twilio's servers instead of building an ``HttpResponse`` object
          manually.

          .. note::
            The forgery protection checks ONLY happen if ``settings.DEBUG =
            False`` (aka, your site is in production).

    Usage::

        from twilio import twiml

        @twilio_view
        def my_view(request):
            r = twiml.Response()
            r.message('Thanks for the SMS message!')
            return r
    """

    @csrf_exempt
    @wraps(f)
    def decorator(request_or_self, *args, **kwargs):

        class_based_view = not isinstance(request_or_self, HttpRequest)
        if not class_based_view:
            request = request_or_self
        else:
            assert len(args) >= 1
            request = args[0]

        # Turn off Twilio authentication when explicitly requested, or
        # in debug mode. Otherwise things do not work properly. For
        # more information, see the docs.
        use_forgery_protection = getattr(
            settings,
            'DJANGO_TWILIO_FORGERY_PROTECTION',
            not settings.DEBUG,
        )
        if use_forgery_protection:

            if request.method not in ['GET', 'POST']:
                return HttpResponseNotAllowed(request.method)

            # Forgery check
            try:
                validator = RequestValidator(settings.TWILIO_AUTH_TOKEN)
                url = request.build_absolute_uri()
                signature = request.META['HTTP_X_TWILIO_SIGNATURE']
            except (AttributeError, KeyError):
                return HttpResponseForbidden()

            if request.method == 'POST':
                if not validator.validate(url, request.POST, signature):
                    return HttpResponseForbidden()
            if request.method == 'GET':
                if not validator.validate(url, request.GET, signature):
                    return HttpResponseForbidden()

        response = f(request_or_self, *args, **kwargs)

        return response

    return decorator
