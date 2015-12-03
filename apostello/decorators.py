# -*- coding: utf-8 -*-
from functools import partial, wraps

from django.conf import settings
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.shortcuts import redirect

from apostello.models import Keyword


def keyword_access_check(method):
    """Checks a user can access a specific keyword."""

    @wraps(method)
    def wrapper(request, *args, **kwargs):
        if request.user.is_staff:
            return method(request, *args, **kwargs)
        try:
            keyword = Keyword.objects.get(pk=kwargs['pk'])
            if keyword.is_locked():
                if not keyword.can_user_access(request.user):
                    messages.warning(request, settings.NO_ACCESS_WARNING)
                    return redirect(reverse('keywords'))
        except Keyword.DoesNotExist:
            pass

        return method(request, *args, **kwargs)

    return wrapper


def check_user_perms(view=None, require=None):
    """Checks a user has the specified permissions."""
    if view is None:
        return partial(check_user_perms, require=require)

    @wraps(view)
    def f(*args, **kwargs):
        request = args[0]
        if request.user.is_staff:
            return view(*args, **kwargs)

        if require is None:
            # if no requirements, then limit to staff
            if request.user.is_staff:
                return view(*args, **kwargs)
        else:
            # check for anon users:
            # this hsould not be neccessary, but it works...
            if not request.user.is_authenticated():
                return redirect(settings.LOGIN_URL)
            # check approval status:
            if not request.user.profile.approved:
                return redirect(reverse('not_approved'))
            # check user has required permissions
            tested_perms = [request.user.profile.__getattribute__(x) for x in require]
            if all(tested_perms):
                return view(*args, **kwargs)

        messages.warning(request, settings.NO_ACCESS_WARNING)
        return redirect('/')

    return f
