# -*- coding: utf-8 -*-
import re

import ElvantoAPI
from django.conf import settings

from apostello.tasks import send_async_mail


def elvanto():
    """Shortcut to create Elvanto API instance"""
    return ElvantoAPI.Connection(APIKey=settings.ELVANTO_KEY)


def grab_elvanto_groups():
    """
    Returns a list of elvanto groups.
    Each group is a tuple: ('group id', 'group name').

    TODO: replace with a list of named tuples
    """
    e_api = elvanto()
    data = e_api._Post("groups/getAll")
    if data['status'] == 'ok':
        return [(x['id'], x['name']) for x in data['groups']['group']]
    else:
        return []


def fix_elvanto_numbers(num_string):
    """
    Checks if number starts with +447 or 077 and normalises

    TODO: modify for other locales
    """
    number = re.sub("[^0-9]", "", num_string)
    if number.startswith(settings.COUNTRY_CODE + '7'):
        number = "+" + number
    elif number.startswith('07'):
        number = "+" + settings.COUNTRY_CODE + number[1:]
    else:
        number = None

    return number


def try_both_num_fields(mobile, phone):
    """
    Returns a person's phone number by checking both the
    'mobile' and 'phone' fields.
    """
    mobile_ = fix_elvanto_numbers(mobile)
    final_num = mobile_ if mobile_ is not None else fix_elvanto_numbers(phone)
    return final_num


def grab_elvanto_people(group_id):
    """
    Returns the group name and a list of dictionaries.
    Each dictionary has a "number", "first_name" and "last_name"
    for each person.

    An empty list is returned if the group is empty.

    TODO: return a list of namedtuples
    TODO: do not return empty list, raise exception
    """
    e_api = elvanto()
    data = e_api._Post("groups/getInfo", id=group_id, fields=['people'])
    group_name = data['group'][0]['name']
    if data['status'] == 'ok' and len(data['group'][0]['people']) > 0:
        return group_name, [{'number': try_both_num_fields(x['mobile'], x['phone']),
                             'first_name': x['firstname'],
                             'last_name': x['lastname']} for x in data['group'][0]['people']['person']]
    else:
        return group_name, []


def import_elvanto_groups(group_ids, user_email):
    """
    Imports all people from groups provided.
    """
    from apostello.models import Recipient, RecipientGroup
    for group_id in group_ids:
        bad_ppl = list()
        group_name, ppl = grab_elvanto_people(group_id)
        group = RecipientGroup.objects.get_or_create(name='[E] ' + group_name)[0]
        group.is_archived = False
        group.recipient_set.clear()
        try:
            person = ""
            for person in ppl:
                number = str(person['number'])
                obj = Recipient.objects.get_or_create(number=number)[0]
                obj.first_name = person['first_name']
                obj.last_name = person['last_name']
                obj.is_archived = False
                obj.full_clean()
                obj.save()
                group.recipient_set.add(obj)
        except Exception:
            bad_ppl.append(person)

        group.save()
        if bad_ppl:
            # send email with failed data
            failed_people = ""
            for p in bad_ppl:
                failed_people += "\t{fn} {ln} ({num})\n\n".format(fn=p['first_name'],
                                                                  ln=p['last_name'],
                                                                  num=p['number'])
            email_body = 'Some of your import of "{}"" failed.\n\n'
            email_body += 'Please update the following people in Elvanto and try again.\n{}'
            email_body = email_body.format(group_name, failed_people)

            send_async_mail.delay('[Apostello] Failed Elvanto Group Import' + group_name,
                                  email_body,
                                  [user_email])
        else:
            # send good email
            send_async_mail.delay('[Apostello] Successful Elvanto Group Import',
                                  '"{}" was imported successfully.'.format(group_name),
                                  [user_email])
