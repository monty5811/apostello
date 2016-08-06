import csv
import io

from django.contrib import messages
from django.template.response import TemplateResponse
from django.views.generic import FormView
from phonenumber_field.validators import validate_international_phonenumber

from apostello.forms import CsvImport
from apostello.mixins import ProfilePermsMixin
from apostello.models import Recipient


class ImportRecipients(ProfilePermsMixin, FormView):
    form_class = CsvImport
    success_url = '/'
    required_perms = []
    template_name = 'apostello/importer.html'

    def form_valid(self, form):
        csv_string = u"first_name,last_name,number\n" + form.cleaned_data[
            'csv_data'
        ]
        data = [x for x in csv.DictReader(io.StringIO(csv_string))]
        bad_rows = list()
        for row in data:
            try:
                validate_international_phonenumber(row['number'])
                obj = Recipient.objects.get_or_create(
                    number=row['number']
                )[0]
                obj.first_name = row['first_name'].strip()
                obj.last_name = row['last_name'].strip()
                obj.is_archived = False
                obj.full_clean()
                obj.save()
            except Exception:
                # catch bad rows and display to the user
                bad_rows.append(row)

        if bad_rows:
            messages.warning(
                self.request, "Uh oh, something went wrong with these imports!"
            )
            context = {}
            context['form'] = CsvImport()
            context['bad_rows'] = bad_rows
            return TemplateResponse(self.request, self.template_name, context)
        else:
            messages.success(self.request, "Importing your data now...")
            return super(ImportRecipients, self).form_valid(form)
