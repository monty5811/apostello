# -*- coding: utf-8 -*-
from django.contrib.auth.decorators import login_required

from apostello.decorators import check_user_perms


class LoginRequiredMixin(object):
    """
    Checks if a user is logged in.
    Redirects to login page otherwise.

    TODO: Remove when Django 1.9 is released.
    """
    @classmethod
    def as_view(cls, **initkwargs):
        view = super(LoginRequiredMixin, cls).as_view(**initkwargs)
        return login_required(view)


class ProfilePermsMixin(object):
    """
    Checks if a user is staff or has permission.
    Redirects to '/' otherwise.
    """
    @classmethod
    def as_view(cls, **initkwargs):
        view = super(ProfilePermsMixin, cls).as_view(**initkwargs)
        try:
            return check_user_perms(view, require=initkwargs['required_perms'])
        except KeyError:
            return check_user_perms(view)
