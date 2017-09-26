import re
import subprocess

from django.core.management.base import BaseCommand
from django.urls.resolvers import RegexURLPattern, RegexURLResolver

from apostello.urls import urlpatterns

arg_re = re.compile(r'<\w*>')

IGNORED_URLS = ('/accounts/confirm-', '/accounts/password/reset/', '/admin', '/__debug__', '/sw', '/.*')

TYPES = {
    'pk': 'Int',
    'keyword': 'String',
}


def safe_name(name):
    name = name.replace('-', '_')
    name = name.replace(':', '_')
    return name


def extract_types(url, optional):
    types = []
    args_ = []
    matches = arg_re.findall(url)
    for m_ in matches:
        m = m_.replace('<', '').replace('>', '')
        if m in TYPES:
            t = TYPES[m]
            if optional:
                t = f'Maybe {t}'
            types.append(t)
            args_.append(m)

    return types, args_


def indent(n):
    return '    ' * n


def case_template(a, convert_b):
    t = f'''"
        ++ (case {a} of
                Just b ->
                    {convert_b} ++ "/"

                Nothing ->
                    ""
           )'''

    return t


def argTypeConv(a, t, optional):
    if optional:
        if t == 'String':
            s = case_template(a, "b")
        else:
            s = case_template(a, "toString b")
    else:
        if t == 'String':
            s = f'" ++ {a} ++ "/'
        else:
            s = f'" ++ toString {a} ++ "/'

    return s


def extract_body(url, types, args_, optional):
    if not types:
        return f'"{url}"'

    for t, a in zip(types, args_):
        arg_w_brackets = '<' + a + '>/'
        url = url.replace(arg_w_brackets, argTypeConv(a, t, optional))

    if not url.endswith(')'):
        url = url + '"'

    return '"' + url


def clean_url(url):
    url = url.replace('(?:(?P', '')
    url = url.replace('\\w+)', '')
    url = url.replace('\\d+)', '')
    url = url.replace('[\\d|\\w]+)', '')
    url = url.replace('(?P', '')
    url = url.replace('^', '')
    url = url.replace('$', '')
    url = url.replace('[-:\w]+)', '')
    url = url.replace(')?', '')
    url = url.replace('[0-9]+)', '')

    if url.startswith('/'):
        return url
    else:
        return '/' + url


def convert_to_elm(u):
    name = u['name']
    url = u['url']
    optional = '(?:' in url

    url = clean_url(url)
    if url.startswith(IGNORED_URLS):
        return None

    if not name:
        return None

    name = safe_name(name)
    types, args_ = extract_types(url, optional)
    body = extract_body(url, types, args_, optional)

    typeDef = f'{name} : {" -> ".join(types + ["String"])}'
    funcDef = " ".join([name] + args_ + ["="])
    funcBody = f'    {body}'
    return '\n'.join([typeDef, funcDef, funcBody])


def add_namespacing(top, url):
    if top.namespace is not None:
        url['name'] = top.namespace + ':' + url['name']

    if isinstance(url['url'], tuple):
        url['url'] = url['url'][0]
    url['url'] = top.regex.pattern + url['url']
    return url


def extract_urls(urlpatterns):
    url_data = []
    for u in urlpatterns:
        if isinstance(u, RegexURLPattern):
            if u.name is not None:
                url_data.append({
                    'url': u.regex.pattern,
                    'name': u.name,
                })
        elif isinstance(u, RegexURLResolver):
            tmp_urls = extract_urls(u.url_patterns)
            tmp_urls = [add_namespacing(u, tmp) for tmp in tmp_urls]
            url_data += tmp_urls

    return url_data


def generate_module():
    url_data = extract_urls(urlpatterns)

    funcs = [convert_to_elm(u) for u in url_data]
    funcs = [f for f in funcs if f is not None]
    funcs = sorted(list(set(funcs)))

    module = 'module Urls exposing (..)\n\n\n' + '\n\n\n'.join(funcs) + '\n'

    return module


class Command(BaseCommand):
    """Parse urls and write to Elm file."""
    args = ''
    help = 'Parse urls and write to Elm file.'

    def handle(self, *args, **options):
        """Handle the command."""
        module = generate_module()

        with open('assets/elm/Urls.elm', 'w') as f:
            f.write(module)

        subprocess.run(f'elm-format --yes assets/elm/Urls.elm'.split())
