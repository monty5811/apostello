# -*- coding: utf-8 -*-
import re

gsm_regex = re.compile(r'^[\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\']+$')
non_gsm_regex = re.compile(r'[^\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\'\s]')


def exists_and_archived(form, model_class, identifier):
    """
    Checks if a user tries to create a Person, Group or Keyword
    that existed in the past, but is now archived.
    Returns the instance of the existing Person (etc) for editing if it exists,
    otherwise returns None.
    """
    unique_fields = {'keyword': 'keyword',
                     'group': 'name',
                     'recipient': 'number'}

    all_errors = [form.errors.as_data()[x][0].code for x in form.errors.as_data()]
    try:
        instance = model_class.objects.get(**{unique_fields[identifier]: form.data[unique_fields[identifier]]})
    except Exception:
        return None

    if 'unique' in all_errors:
        if instance.is_archived:
            return instance

    return None


def fetch_default_reply(msg=''):
    from apostello.models import DefaultResponses
    replies = DefaultResponses.get_solo().__dict__
    return replies[msg]
