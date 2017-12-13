from allauth.account.signals import user_signed_up
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User

from apostello.tasks import send_async_mail
from apostello.models import UserProfile


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
        send_async_mail(
            "[apostello] New User",
            body,
            [to_],
        )


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)
    instance.profile.save()
