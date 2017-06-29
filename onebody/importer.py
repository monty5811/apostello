import csv
import io
import logging
from time import sleep

import requests
from django.core.exceptions import ValidationError
from django.conf import settings
from django.utils import timezone
from phonenumber_field.validators import validate_international_phonenumber

from apostello.models import Recipient, RecipientGroup
from elvanto.exceptions import NotValidPhoneNumber

logger = logging.getLogger('apostello')

WAIT_TIME = 10


class OnebodyException(Exception):
    pass


def import_onebody_csv():
    base_url = settings.ONEBODY_BASE_URL
    user_email = settings.ONEBODY_USER_EMAIL
    key = settings.ONEBODY_API_KEY
    if not any([base_url, user_email, key]):
        logger.info('Onebody Sync Disabled')
        return

    resp = requests.get(
        base_url + '/people.csv',
        auth=(user_email, key),
        allow_redirects=False,
    )
    resp.raise_for_status()

    csv_url = resp.headers['Location']

    sleep(WAIT_TIME) # wait for csv to be generated
    tries = 0
    max_tries = 10
    while tries <= max_tries:
        try:
            csv_resp = requests.get(
                csv_url,
                auth=(user_email, key),
            )
            csv_resp.raise_for_status()
            data = csv.DictReader(io.StringIO(csv_resp.text))
            break
        except Exception:
            sleep(WAIT_TIME)
            if tries >= max_tries:
                logger.warning('Failed to get CSV from onebody')
                raise OnebodyException('Failed to get CSV from onebody')
            tries += 1

    # we now have the good data, let's import it:
    grp, _ = RecipientGroup.objects.get_or_create(name='[onebody]', description='imported from onebody')
    for row in data:
        try:
            number = row['mobile_phone']
            if not number.startswith('+'):
                number = '+' + number
            validate_international_phonenumber(number)
            prsn_obj = Recipient.objects.get_or_create(number=number)[0]
            prsn_obj.first_name = row['first_name'].strip()
            prsn_obj.last_name = row['last_name'].strip()
            prsn_obj.save()
            # add person to group
            grp.recipient_set.add(prsn_obj)
        except ValidationError:
            logger.warning('Failed to import - bad number: %s %s (%s)', row['first_name'], row['last_name'], number)
        except Exception:
            logging.exception('Failed to import %s %s (%s)', row['first_name'], row['last_name'], number)
