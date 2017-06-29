import pytest
from django.core.management import call_command
from django_q.models import Schedule
from tests.conftest import twilio_vcr


@pytest.mark.django_db
class TestManagementCommands():
    def test_update_sms_name_fields(self, recipients, smsin):
        """Test update sms name fields command."""
        call_command('update_sms_name_fields')

    @twilio_vcr
    def test_import_in(self):
        """Test import incoming sms command."""
        call_command('import_incoming_sms')

    @twilio_vcr
    def test_import_out(self):
        """Test import outgoing sms command."""
        call_command('import_outgoing_sms')

    def test_setup_scheduled_tasks(self):
        """Test setup of perdiodic tasks and ensure function is idempotent."""
        call_command('setup_periodic_tasks')
        assert Schedule.objects.all().count() == 5
        call_command('setup_periodic_tasks')
        assert Schedule.objects.all().count() == 5
