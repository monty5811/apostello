# -*- coding: utf-8 -*-
import pytest

from ..forms import (ManageRecipientGroupForm, SendAdhocRecipientsForm,
                     SendRecipientGroupForm)


@pytest.mark.django_db
class TestAdhocForm():
    def test_correct_single(self, recipients):
        form_data = {'content': 'This is a message',
                     'recipients': ['1']}  # recipient is first in choice field
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid()

    def test_correct_multiple(self, recipients):
        form_data = {'content': 'This is a message',
                     'recipients': ['1', '2']}  # recipient is first in choice field
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid()

    def test_missing_person(self):
        form_data = {'content': 'This is a message'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_missing_content(self, recipients):
        form_data = {'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_content(self, recipients):
        form_data = {'content': '',
                     'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_person(self):
        form_data = {'content': 'Hi!',
                     'recipient': ''}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_max_length(self, recipients):
        form_data = {'content': 50 * "test",
                     'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_illegal_chars(self, recipients):
        form_data = {'content': u"This should not pass…",
                     'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False


@pytest.mark.django_db
class TestSendGroups():

    def test_correct_values(self, groups):
        form_data = {'content': 'This is a message',
                     'recipient_group': '1'}  # recipient is first in choice field
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid()

    def test_missing_group(self, groups):
        form_data = {'content': 'This is a message'}
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_missing_content(self, groups):
        form_data = {'recipient_group': '1'}
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_content(self, groups):
        form_data = {'content': '',
                     'recipient_group': '1'}
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_group(self):
        form_data = {'content': 'Hi!',
                     'recipient_group': ''}
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_illegal_chars(self, groups):
        form_data = {'content': u"This should not pass…",
                     'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_max_length(self, groups):
        form_data = {'content': 50 * "test",
                     'recipient': '1'}
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_archived(self, groups):
        form_data = {'content': 'This is a message',
                     'recipient_group': '2'}  # recipient is first in choice field
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False


@pytest.mark.django_db
class TestManageGroups():
    def test_correct_inputs(self, recipients, groups):
        form_data = {'name': 'test_new_group',
                     'description': 'not very interesting',
                     'members': ['1']}
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid()
        form.save()

    def test_invalid_members(self, recipients, groups):
        form_data = {'name': 'test_new_group',
                     'description': 'not very interesting',
                     'members': ['57']}
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_no_members(self):
        form_data = {'name': 'test_new_group',
                     'description': 'not very interesting',
                     'members': []}
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid()

    def test_duplicate_group(self, recipients, groups):
        form_data = {'name': 'Test Group',
                     'description': 'not very interesting',
                     'members': ['1']}
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_duplicate_archived_group(self, recipients, groups):
        form_data = {'name': 'Archived Group',
                     'description': 'not very interesting',
                     'members': ['1']}
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid() is False
