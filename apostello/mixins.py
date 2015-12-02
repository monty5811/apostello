# -*- coding: utf-8 -*-
from apostello.decorators import check_user_perms


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
