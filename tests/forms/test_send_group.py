import pytest

from apostello.forms import SendRecipientGroupForm


class ProfileMock:
    message_cost_limit = 50


class UserMock:
    profile = ProfileMock()


@pytest.mark.django_db
class TestSendGroupsValid():
    """Tests Send to Group form with valid inputs"""

    def test_correct_values(self, groups):
        form_data = {
            'content': 'This is a message',
            'recipient_group': groups['test_group'].pk,
        }
        form = SendRecipientGroupForm(data=form_data, user=UserMock())
        assert form.is_valid()

    def test_fails_user_limit(self, groups):
        """Tests the SMS cost limit check."""
        form_data = {
            'content': 'This is a message',
            'recipient_group': groups['test_group'].pk,
        }
        user = UserMock()
        user.profile.message_cost_limit = 0.01
        form = SendRecipientGroupForm(data=form_data, user=UserMock())
        assert not form.is_valid()
        assert 'cost no more than ${0}'.format(
            user.profile.message_cost_limit
        ) in '\n'.join(form.errors['__all__'])

    def test_disabled_user_limit(self, groups):
        """Tests the SMS cost limit check is disabled."""
        form_data = {
            'content': 'This is a message',
            'recipient_group': groups['test_group'].pk,
        }
        user = UserMock()
        user.profile.message_cost_limit = 0
        form = SendRecipientGroupForm(data=form_data, user=UserMock())
        assert form.is_valid()


@pytest.mark.django_db
class TestSendGroupsInvalid():
    """Tests apostello.forms.SendRecipientGroupForm"""

    def test_missing_group(self, groups):
        """Test missing group"""
        form_data = {'content': 'This is a message', }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_missing_content(self, groups):
        """Test missing content"""
        form_data = {'recipient_group': '1', }
        form = SendRecipientGroupForm(data=form_data, user=UserMock())
        assert form.is_valid() is False

    def test_empty_content(self, groups):
        """Test empty content"""
        form_data = {
            'content': '',
            'recipient_group': '1',
        }
        form = SendRecipientGroupForm(data=form_data, user=UserMock())
        assert form.is_valid() is False

    def test_empty_group(self):
        """Test empty group"""
        form_data = {
            'content': 'Hi!',
            'recipient_group': '',
        }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_illegal_chars(self, groups):
        """Test illegal (non-GSM) characters"""
        form_data = {
            'content': u"This should not pass…",
            'recipient': ['1'],
        }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_max_length(self, groups):
        """Test message far too long"""
        form_data = {
            'content': 50 * "test",
            'recipient': ['1'],
        }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_archived(self, groups):
        """Test archived group"""
        form_data = {
            'content': 'This is a message',
            'recipient_group': '2',
        }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False
