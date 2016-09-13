import json
import re

from django.conf import settings

from apostello.utils import retry_request
from elvanto.exceptions import ElvantoException, NotValidPhoneNumber


def elvanto(end_point, **kwargs):
    """Shortcut to create Elvanto API instance."""
    base_url = 'https://api.elvanto.com/v1/'
    e_url = '{0}{1}.json'.format(base_url, end_point)
    resp = retry_request(
        e_url, 'post', json=kwargs, auth=(settings.ELVANTO_KEY, '_')
    )
    data = json.loads(resp.text)
    if data['status'] == 'ok':
        return data
    else:
        raise ElvantoException(data['error'])


def fix_elvanto_numbers(num_string):
    """
    Check if number starts with +447 or 077 and normalises.

    TODO: modify for other locales.
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
    """Return a person's phone number by checking both the 'mobile' and 'phone' fields."""
    try:
        number = fix_elvanto_numbers(mobile)
    except NotValidPhoneNumber:
        number = fix_elvanto_numbers(phone)

    return number
