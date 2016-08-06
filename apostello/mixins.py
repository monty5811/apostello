# -*- coding: utf-8 -*-
from django.contrib.auth.mixins import LoginRequiredMixin
from apostello.decorators import check_user_perms


class ProfilePermsMixin(LoginRequiredMixin):
    """
    Check if a user is staff or has permission.

    Redirects to '/' otherwise.
    """

    @classmethod
    def as_view(cls, **initkwargs):
        """Wraps view with `check_user_perms` decorator."""
        view = super(ProfilePermsMixin, cls).as_view(**initkwargs)
        try:
            return check_user_perms(view, require=initkwargs['required_perms'])
        except KeyError:
            return check_user_perms(view)
