import os
import subprocess

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
    'CreateAllGroup': ap_forms.GroupAllCreateForm,
    'DefaultResponses': sc_forms.DefaultResponsesForm,
    'UserProfile': ap_forms.UserProfileForm,
    'ContactImport': ap_forms.CsvImport,
}


def esc(text):
    return text.replace('"', '\\"').replace('\n', '\\n')


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

    txt = f'{field_name} = FieldMeta {req} "id_{field_name}" "{field_name}" "{esc(label)}" {help_text}'
    return txt


def generate_module(name, form_):
    form = form_()
    elm = f'module Pages.Forms.Meta.{name} exposing (meta)\n\n'
    elm += 'import Forms.Model exposing (FieldMeta)\n\n\n'
    elm += 'meta : { '
    elm += ', '.join([f'{name} : FieldMeta' for name in form.base_fields])
    elm += ' }\n'
    elm += 'meta =\n    { '
    fields_text = '\n    , '.join([field_text(field_name, field) for field_name, field in form.base_fields.items()])
    elm += f'{fields_text}\n    }}\n'
    dir_name = 'assets/elm/Pages/Forms/Meta'
    fname = os.path.join(dir_name, f'{name}.elm')

    return elm, fname


def write_form(elm, fname):
    dir_name = os.path.dirname(fname)
    if not os.path.exists(dir_name):
        os.mkdir(dir_name)

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
            module, fname = generate_module(n, f)
            write_form(module, fname)
