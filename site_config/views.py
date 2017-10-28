import os
import traceback
from collections import namedtuple

from django.conf import settings
from django.contrib.auth.models import User
from django.core.cache import cache
from django.http import JsonResponse
from django.shortcuts import redirect
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.generic import TemplateView, View
from rest_framework.parsers import JSONParser
from twilio.base.exceptions import TwilioException

from apostello.twilio import get_twilio_client
from site_config.models import SiteConfiguration

EnvVarSetting = namedtuple('EnvVarSetting', ['env_var_name', 'info', 'val'])


@method_decorator(ensure_csrf_cookie, name='dispatch')
class FirstRunView(TemplateView):
    """View to make initial run experience easier."""
    template_name = 'apostello/first_run.html'

    def get(self, request, *args, **kwargs):
        """Deny access if already setup."""
        if User.objects.count() > 0:
            # once we have a user set up, deny access to this view
            return redirect('/')
        return super(FirstRunView, self).get(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        """Inject data into context."""
        context = super(FirstRunView, self).get_context_data(**kwargs)
        context['variables'] = [
            EnvVarSetting('DJANGO_TIME_ZONE', 'Your timezone (e.g. "Europe/London")', settings.TIME_ZONE),
            EnvVarSetting(
                'WHITELISTED_LOGIN_DOMAINS',
                'Any users that sign up with an email address matching this domain will be granted "approved" status automatically',
                '\n'.join(settings.WHITELISTED_LOGIN_DOMAINS)
            ),
            EnvVarSetting(
                'ACCOUNT_DEFAULT_HTTP_PROTOCOL', 'Set to "http" if you do not have SSL setup',
                settings.ACCOUNT_DEFAULT_HTTP_PROTOCOL
            ),
            EnvVarSetting('ELVANTO_KEY', 'Your Elvanto API key', settings.ELVANTO_KEY),
            EnvVarSetting('COUNTRY_CODE', 'Used to normalise numbers from Elvanto', settings.COUNTRY_CODE),
            EnvVarSetting(
                'LE_EMAIL',
                'This is the email address associated with your Let\'s Encrypt certificate. This is only required with Ansible deploys.',
                os.environ.get('LE_EMAIL')
            ),
        ]

        return context


class TestSetupView(View):
    """Calls self.run_test() on post."""

    def run_test(self, request, *args, **kwargs):
        """Placeholder for run_test method."""
        raise NotImplementedError

    def post(self, request, *args, **kwargs):
        """Actually run the test."""
        try:
            data = JSONParser().parse(request)
            self.run_test(data, *args, **kwargs)
            return JsonResponse({'status': 'success'})
        except Exception:
            tb = ''.join(traceback.format_exc())
            response = JsonResponse({
                'status': 'failed',
                'error': tb,
            })
            response.status_code = 400
            return response


class TestEmailView(TestSetupView):
    """Send a test email."""

    def run_test(self, data, *args, **kwargs):
        """Send message to posted address."""
        from apostello.tasks import send_async_mail
        send_async_mail('apostello test email', data['body_'], [data['to_']])


class TestSmsView(TestSetupView):
    """Send a test SMS."""

    def run_test(self, data, *args, **kwargs):
        """Send message to posted number."""
        twilio_num = str(SiteConfiguration.get_solo().twilio_from_num)
        get_twilio_client().messages.create(body=data['body_'], to=data['to_'], from_=twilio_num)


class CreateSuperUser(TestSetupView):
    """Create a superuser."""

    def post(self, request, *args, **kwargs):
        """Override post to first check if any users exist already."""
        if User.objects.count() > 0:
            response = JsonResponse({'status': 'denied'})
            response.status_code = 403
            return response
        else:
            return super().post(request, *args, **kwargs)

    def run_test(self, data, *args, **kwargs):
        """Create a new user and grant them full access rights."""
        user = User.objects.create_user('admin', data['email_'], data['pass_'])
        user.is_staff = True
        user.is_superuser = True
        user.save()
        cache.set('number_of_users', None, 0)
        from apostello.models import UserProfile
        profile = UserProfile.objects.get_or_create(user=user)[0]
        profile.approved = True
        profile.save()
        # we don't want to send the admin an email confirmation
        from allauth.account.models import EmailAddress, EmailConfirmation
        email = EmailAddress.objects.create(
            user=user,
            email=data['email_'],
        )
        email.save()
        email_confirm = EmailConfirmation.create(email_address=email)
        email_confirm.save()
        email = EmailAddress.objects.get(email=data['email_'])
        email.verified = True
        email.primary = True
        email.save()
