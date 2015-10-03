# -*- coding: utf-8 -*-
from django.contrib.auth.decorators import login_required

from apostello.decorators import check_user_perms


class LoginRequiredMixin(object):
    @classmethod
    def as_view(cls, **initkwargs):
        view = super(LoginRequiredMixin, cls).as_view(**initkwargs)
        return login_required(view)


class ProfilePermsMixin(object):
    @classmethod
    def as_view(cls, **initkwargs):
        view = super(ProfilePermsMixin, cls).as_view(**initkwargs)
        try:
            return check_user_perms(view, require=initkwargs['required_perms'])
        except KeyError:
            return check_user_perms(view)
