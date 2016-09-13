import pytest

from apostello.forms import ManageRecipientGroupForm


@pytest.mark.django_db
class TestManageGroups():
    def test_correct_inputs(self, recipients, groups):
        form_data = {
            'name': 'test_new_group',
            'description': 'not very interesting',
        }
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid()
        form.save()

    def test_duplicate_group(self, recipients, groups):
        form_data = {
            'name': 'Test Group',
            'description': 'not very interesting',
        }
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_duplicate_archived_group(self, recipients, groups):
        form_data = {
            'name': 'Archived Group',
            'description': 'not very interesting',
        }
        form = ManageRecipientGroupForm(data=form_data)
        assert form.is_valid() is False
