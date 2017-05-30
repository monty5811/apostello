import re

import requests

gsm_regex = re.compile(r'^[\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\']+$')
non_gsm_regex = re.compile(r'[^\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\'\s]')


def fetch_default_reply(msg=''):
    """Fetch default reply from database."""
    from site_config.models import DefaultResponses
    replies = DefaultResponses.get_solo().__dict__
    return replies[msg]


def retry_request(url, http_method, *args, **kwargs):
    """Make a http request and retry 3 times if it fails."""
    assert http_method in ['get', 'post', 'delete', 'patch', 'put']
    MAX_TRIES = 3
    r_func = getattr(requests, http_method)
    tries = 0
    while True:
        resp = r_func(url, *args, **kwargs)
        if resp.status_code != 200 and tries < MAX_TRIES:
            tries += 1
            continue
        break

    return resp
