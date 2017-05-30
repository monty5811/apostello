import subprocess

import ipdb
from django.core.management.base import BaseCommand

from apostello import forms as ap_forms
from site_config import forms as sc_forms


FORMS = {
    'SiteConfig': sc_forms.SiteConfigurationForm,
    'Keyword': ap_forms.KeywordForm,
    'Contact': ap_forms.RecipientForm,
    'Group': ap_forms.ManageRecipientGroupForm,
    'SendAdhoc': ap_forms.SendAdhocRecipientsForm,
    'SendGroup': ap_forms.SendRecipientGroupForm,
}


def esc(text):
    return text.replace('"', '\\"')


def field_text(field_name, field):
    if field.label is None:
        label = field_name.capitalize()
    else:
        label = field.label
    if field.help_text:
        help_text = f'(Just "{esc(field.help_text)}")'
    else:
        help_text = "Nothing"

    if field.required:
        req = "True"
    else:
        req = "False"

    txt =  f'{field_name} = FieldMeta {req} "id_{field_name}"  "{field_name}"  "{esc(label)}" {help_text}'
    return txt



def write_form(name, form_):
    form = form_()
    elm = f'module Pages.{name}Form.Meta exposing (meta)\n'
    elm += 'import Forms.Model exposing (FieldMeta)\n'
    elm += 'meta : {'
    elm += ','.join([f'{name} : FieldMeta' for name in form.base_fields])
    elm += '}\n'
    elm += 'meta = \n{\n'
    fields_text = '\n    ,'.join(
        [field_text(field_name, field) for field_name, field in form.base_fields.items()]
    )
    elm += f'{fields_text}\n}}'
    fname = f'assets/elm/Pages/{name}Form/Meta.elm'
    with open(fname, 'w') as f:
        f.write(elm)
    subprocess.run(f'elm-format --yes {fname}'.split())


class Command(BaseCommand):
    """Parse urls and write to Elm file."""
    args = ''
    help = 'Parse urls and write to Elm file.'

    def handle(self, *args, **options):
        """Handle the command."""
        for n, f in FORMS.items():
            write_form(n, f)
