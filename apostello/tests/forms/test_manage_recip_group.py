# -*- coding: utf-8 -*-
import pytest

from apostello.forms import ManageRecipientGroupForm


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
