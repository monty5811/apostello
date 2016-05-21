from django.contrib.auth.models import User
from django.core.cache import cache
from django.http import HttpResponseRedirect


class FirstRunRedirect:
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
