# -*- coding: utf-8 -*-
from django.core.mail import send_mail
from django.dispatch import receiver

from allauth.account.signals import user_signed_up


@receiver(user_signed_up)
def email_admin_on_signup(request, user, **kwargs):
    body = ("New User Signed Up: {}\n\n"
            "Please go to the admin page to approve their account.\n"
            "If you do not approve their account, they will be unable "
            "to access apostello.")
    body = body.format(str(user))
    from apostello.models import SiteConfiguration
    to_ = [SiteConfiguration.get_solo().office_email]
    send_mail(
        "[apostello] New User",
        body,
        '',
        to_,
    )
