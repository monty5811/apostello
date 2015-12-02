# -*- coding: utf-8 -*-
import re

import ElvantoAPI
from django.conf import settings

from apostello.exceptions import NotValidPhoneNumber


def elvanto():
    """Shortcut to create Elvanto API instance"""
    return ElvantoAPI.Connection(APIKey=settings.ELVANTO_KEY)


def fix_elvanto_numbers(num_string):
    """
    Checks if number starts with +447 or 077 and normalises

    TODO: modify for other locales
    """
    number = re.sub("[^0-9]", "", num_string)
    if number.startswith(settings.COUNTRY_CODE + '7'):
        number = "+" + number
        return number
    if number.startswith('07'):
        number = "+" + settings.COUNTRY_CODE + number[1:]
        return number

    raise NotValidPhoneNumber


def try_both_num_fields(mobile, phone):
    """
    Returns a person's phone number by checking both the
    'mobile' and 'phone' fields.
    """
    try:
        number = fix_elvanto_numbers(mobile)
    except NotValidPhoneNumber:
        number = fix_elvanto_numbers(phone)

    return number
