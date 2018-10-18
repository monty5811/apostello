import pytest
from django.core.management import call_command
from django_q.models import Schedule
from tests.conftest import twilio_vcr

from apostello.management.commands.write_urls_to_elm import generate_module as generate_urls
from apostello.management.commands import write_form_meta_to_elm as form_meta


@pytest.mark.django_db
class TestManagementCommands:
    def test_update_sms_name_fields(self, recipients, smsin):
        """Test update sms name fields command."""
        call_command("update_sms_name_fields")

    @twilio_vcr
    def test_import_in(self):
        """Test import incoming sms command."""
        call_command("import_incoming_sms")

    @twilio_vcr
    def test_import_out(self):
        """Test import outgoing sms command."""
        call_command("import_outgoing_sms")

    def test_setup_scheduled_tasks(self):
        """Test setup of perdiodic tasks and ensure function is idempotent."""
        call_command("setup_periodic_tasks")
        assert Schedule.objects.all().count() == 6
        call_command("setup_periodic_tasks")
        assert Schedule.objects.all().count() == 6

    def test_write_elm_urls(self):
        """Test Elm Urls are up to date."""
        with open("assets/elm/Urls.elm", "r") as f:
            current_urls = f.read()

        new_urls = generate_urls()
        # remove module declaration:
        new_urls = new_urls[new_urls.find("\n") :]
        current_urls = current_urls[current_urls.find("\n") :]
        assert new_urls == current_urls

    def test_write_elm_form_meta(self):
        """Test Elm Forms are up to date."""
        for n, f in form_meta.FORMS.items():
            new_meta, fname = form_meta.generate_module(n, f)
            with open(fname, "r") as f_:
                current_meta = f_.read()
            assert new_meta == current_meta
