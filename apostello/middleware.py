from django.contrib.auth.models import User
from django.core.cache import cache
from django.http import HttpResponseRedirect
from django.utils.deprecation import MiddlewareMixin


class FirstRunRedirect(MiddlewareMixin):
    """
    This middleware will redirect all requests to the setup page (not /sms/).

    This will redirecte all requests to `/config/first_run/` if the User table
    is empty.

    `/sms/` is exempt so we can receive messages from Twilio.
    """

    def process_request(self, request):
        """Check number of users, cache, and then redirect if required."""
        num_users = cache.get('number_of_users')
        if num_users is None:
            num_users = User.objects.count()
            cache.set('number_of_users', num_users, 60 * 60)

        if num_users > 0:
            return

        if not request.path_info.startswith(('/sms', '/config')):
            return HttpResponseRedirect('/config/first_run/')


class JsPathMiddleware(MiddlewareMixin):
    """Inject template name into views so js can lookup file."""

    def process_template_response(self, request, response):
        """Inject the template name if it exists."""
        template_name = response.template_name
        if template_name is None:
            return response

        if type(template_name) is list and len(template_name) < 2:
            template_name = template_name[0]

        if type(template_name) is list and len(template_name) > 1:
            template_name = template_name[-1]

        response.context_data['js_path'] = template_name.replace('.html', '')
        return response
