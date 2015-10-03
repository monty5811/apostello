# -*- coding: utf-8 -*-
from django.core.management import call_command

import pytest


@pytest.mark.django_db
class TestManagementCommands():

    def test_import(self, recipients, smsin):
        call_command('update_sms_name_fields')

    def test_management(self):
        call_command('import_incoming_sms')
