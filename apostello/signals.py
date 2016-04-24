from django.dispatch import receiver

from allauth.account.signals import email_confirmed, user_signed_up
from apostello.tasks import send_async_mail


@receiver(email_confirmed)
def make_first_user_admin(email_address, **kwargs):
    """Grant access to first user."""
    from django.contrib.auth.models import User
    users = User.objects.all()
    if len(users) > 1:
        return
    else:
        # if this is the first user, grant them access to everything
        first_user = users[0]
        first_user.is_staff = True
        first_user.is_superuser = True
        first_user.save()
        from allauth.account.models import EmailAddress
        first_user_email = EmailAddress.objects.get(email=first_user.email)
        first_user_email.verified = True
        first_user_email.save()


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
    if len(to_) > 0:
        send_async_mail("[apostello] New User", body, [to_], )
