# -*- coding: utf-8 -*-
import pytest

from apostello.exceptions import ArchivedItemException
from apostello.forms import ManageRecipientGroupForm
from apostello.models import RecipientGroup
from apostello.utils import exists_and_archived


@pytest.mark.django_db
class TestExistsAndArchived:
    def test_group_archived(self, groups):
        form_data = {'name': 'Archived Group', 'description': 'still not very interesting', 'members': []}
        form = ManageRecipientGroupForm(data=form_data)
        form.is_valid()
        assert exists_and_archived(form, RecipientGroup, 'group').name == 'Archived Group'

    def test_invalid_form(self, groups):
        form_data = {
            'name': 'Test Group',
            # 'description': 'still not very interesting',
            'members': []
        }
        form = ManageRecipientGroupForm(data=form_data)
        form.is_valid()
        with pytest.raises(ArchivedItemException):
            exists_and_archived(form, RecipientGroup, 'group')
