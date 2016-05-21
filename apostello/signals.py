from django.dispatch import receiver

from allauth.account.signals import user_signed_up
from apostello.tasks import send_async_mail


@receiver(user_signed_up)
def email_admin_on_signup(request, user, **kwargs):
    """Email office on new user sign up."""
    body = (
        "New User Signed Up: {}\n\n"
        "Please go to the admin page to approve their account.\n"
        "If you do not approve their account (and they are not using a "
        "whitelisted domain), they will be unable to access apostello."
    )
    body = body.format(str(user))
    from site_config.models import SiteConfiguration
    to_ = SiteConfiguration.get_solo().office_email
    if to_:
        send_async_mail("[apostello] New User", body, [to_], )
