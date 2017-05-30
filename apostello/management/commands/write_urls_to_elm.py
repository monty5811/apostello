import json
import re
import subprocess
from io import StringIO

from django.core.management import call_command
from django.core.management.base import BaseCommand
from django.urls.resolvers import RegexURLPattern, RegexURLResolver

from apostello import urls

arg_re = re.compile(r'<\w*>')

IGNORED_URLS = (
    '/admin',
    '/__debug__',
    '/sw',
    '/.*'
)

TYPES = {
    'pk': 'Int',
    'keyword': 'String',
}

def safe_name(name):
    name = name.replace('-', '_')
    name = name.replace(':', '_')
    return name


def extract_types(url):
    types = []
    args_ = []
    matches = arg_re.findall(url)
    for m_ in matches:
        m = m_.replace('<', '').replace('>', '')
        if m in TYPES:
            types.append(TYPES[m])
            args_.append(m)

    return types, args_


def argTypeConv(a, t):
    if t == 'String':
        return a
    else:
        return f'toString {a}'
    return


def extract_body(url, types, args_):
    for t, a in zip(types, args_):
        arg_w_brackets = '<' + a + '>'
        url = url.replace(arg_w_brackets, f'" ++ {argTypeConv(a, t)} ++ "')
    return url


def convert_to_elm(u):
    name = u['name']
    url = u['url']

    if url.startswith(IGNORED_URLS):
        return None

    if not name:
        return None

    name = safe_name(name)
    types, args_ = extract_types(url)
    body = extract_body(url, types, args_)

    typeDef = f'{name} : {" -> ".join(types + ["String"])}'
    funcDef = f'{name} {"  ".join(args_)} = '
    funcBody = f'    "{body}"'
    return '\n'.join([typeDef, funcDef, funcBody])


class Command(BaseCommand):
    """Parse urls and write to Elm file."""
    args = ''
    help = 'Parse urls and write to Elm file.'

    def handle(self, *args, **options):
        """Handle the command."""
        out = StringIO()
        url_data = json.loads(call_command(
            'show_urls',
            format='json',
            stdout=out,
        ))
        funcs = [convert_to_elm(u) for u in url_data]
        funcs = [f for f in funcs if f is not None]
        funcs = list(set(funcs))

        module = 'module Urls exposing (..)\n\n' + '\n\n'.join(funcs)

        with open('assets/elm/Urls.elm', 'w') as f:
            f.write(module)

        subprocess.run(f'elm-format --yes assets/elm/Urls.elm'.split())
