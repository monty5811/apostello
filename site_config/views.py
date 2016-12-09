import os
import traceback
from collections import namedtuple

from django.conf import settings
from django.contrib import messages
from django.contrib.auth.models import User
from django.core.cache import cache
from django.http import JsonResponse
from django.shortcuts import redirect
from django.views.generic import TemplateView, View
from django.views.generic.edit import UpdateView
from django_twilio.client import twilio_client
from twilio.rest.exceptions import TwilioRestException

from apostello.mixins import ProfilePermsMixin
from site_config.forms import DefaultResponsesForm, SiteConfigurationForm
from site_config.models import DefaultResponses, SiteConfiguration

EnvVarSetting = namedtuple('EnvVarSetting', ['env_var_name', 'info', 'val'])


class SiteConfigView(ProfilePermsMixin, UpdateView):
    """View to handle site config form."""
    template_name = 'site_config/edit_config.html'
    form_class = SiteConfigurationForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        """Retreive the config instance."""
        return SiteConfiguration.get_solo()

    def form_valid(self, form):
        """Handle successful form submission."""
        messages.success(self.request, 'Configuration updated')
        return super(SiteConfigView, self).form_valid(form)


class ResponsesView(ProfilePermsMixin, UpdateView):
    """View to handle default responses form."""
    template_name = 'site_config/edit_responses.html'
    form_class = DefaultResponsesForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        """Retreive the config instance."""
        return DefaultResponses.get_solo()

    def form_valid(self, form):
        """Handle successful form submission."""
        messages.success(self.request, 'Responses updated')
        return super(ResponsesView, self).form_valid(form)


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

        try:
            numbers = twilio_client.phone_numbers.list(
                phone_number=settings.TWILIO_FROM_NUM
            )
            if numbers:
                number = numbers[0]
                sms_url = number.sms_url
                sms_method = number.sms_method
            else:
                sms_url = 'Number not found'
                sms_method = sms_url
        except TwilioRestException:
            sms_url = 'Uh oh, something went wrong, please refresh the page.'
            sms_method = sms_url

        context['number'] = {
            'sms_url': sms_url,
            'sms_method': sms_method,
        }

        context['variables'] = [
            EnvVarSetting(
                'TWILIO_ACCOUNT_SID', 'Your Twilio account SID',
                settings.TWILIO_ACCOUNT_SID
            ),
            EnvVarSetting(
                'TWILIO_AUTH_TOKEN', 'Your Twilio auth ID (hidden)', '****'
            ),
            EnvVarSetting(
                'TWILIO_FROM_NUM', 'Your Twilio number',
                settings.TWILIO_FROM_NUM
            ),
            EnvVarSetting(
                'TWILIO_SENDING_COST',
                'Cost of sending a SMS using Twilio in your country',
                settings.TWILIO_SENDING_COST
            ),
            EnvVarSetting(
                'DJANGO_EMAIL_HOST', 'Email host', settings.EMAIL_HOST
            ),
            EnvVarSetting(
                'DJANGO_EMAIL_HOST_USER', 'Email host user name',
                settings.EMAIL_HOST_USER
            ),
            EnvVarSetting(
                'DJANGO_EMAIL_HOST_PASSWORD', 'Email host password (hidden)',
                '****'
            ),
            EnvVarSetting(
                'DJANGO_FROM_EMAIL', 'Email from which to send',
                settings.EMAIL_FROM
            ),
            EnvVarSetting(
                'DJANGO_EMAIL_HOST_PORT', 'Email host port',
                settings.EMAIL_PORT
            ),
            EnvVarSetting(
                'ACCOUNT_DEFAULT_HTTP_PROTOCOL',
                'Set to "http" if you do not have SSL setup',
                settings.ACCOUNT_DEFAULT_HTTP_PROTOCOL
            ),
            EnvVarSetting(
                'WHITELISTED_LOGIN_DOMAINS',
                'Any users that sign up with an email address matching this domain will be granted "approved" status automatically',
                '\n'.join(settings.WHITELISTED_LOGIN_DOMAINS)
            ),
            EnvVarSetting(
                'DJANGO_TIME_ZONE', 'Your timezone (e.g. "Europe/London"',
                settings.TIME_ZONE
            ),
            EnvVarSetting(
                'DJANGO_SECRET_KEY',
                'This should be a long random string (hidden for security)',
                '****'
            ),
            EnvVarSetting(
                'ELVANTO_KEY', 'Your Elvanto API key', settings.ELVANTO_KEY
            ),
            EnvVarSetting(
                'COUNTRY_CODE', 'Used to normalise numbers from Elvanto',
                settings.COUNTRY_CODE
            ),
            EnvVarSetting(
                'LE_EMAIL',
                'This is the email address associated with youe Let\'s Encrypt certificate. This is only required with Ansible deploys.',
                os.environ.get('LE_EMAIL')
            ),
        ]

        return context


class TestSetupView(View):
    """Calls self.run_test() on post. Only works if User table is empty."""

    def run_test(self, request, *args, **kwargs):
        """Placeholder for run_test method."""
        pass

    def post(self, request, *args, **kwargs):
        """Actually run the test."""

        if User.objects.count() > 0:
            response = JsonResponse({'status': 'denied'})
            response.status_code = 403
            return response

        try:
            self.run_test(request, *args, **kwargs)
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

    def run_test(self, request, *args, **kwargs):
        """Send message to posted address."""
        from apostello.tasks import send_async_mail
        send_async_mail(
            'apostello test email', request.POST['body_'],
            [request.POST['to_']]
        )


class TestSmsView(TestSetupView):
    """Send a test SMS."""

    def run_test(self, request, *args, **kwargs):
        """Send message to posted number."""
        twilio_client.messages.create(
            body=request.POST['body_'],
            to=request.POST['to_'],
            from_=settings.TWILIO_FROM_NUM
        )


class CreateSuperUser(TestSetupView):
    """Create a superuser."""

    def run_test(self, request, *args, **kwargs):
        """Create a new user and grant them full access rights."""
        user = User.objects.create_user(
            'admin', request.POST['email_'], request.POST['pass_']
        )
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
            email=request.POST['email_'],
        )
        email.save()
        email_confirm = EmailConfirmation.create(email_address=email)
        email_confirm.save()
        email = EmailAddress.objects.get(email=request.POST['email_'])
        email.verified = True
        email.primary = True
        email.save()
