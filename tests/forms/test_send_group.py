# -*- coding: utf-8 -*-
import pytest

from apostello.forms import SendRecipientGroupForm


@pytest.mark.django_db
class TestSendGroupsValid():
    """Tests Send to Group form with valid inputs"""

    def test_correct_values(self, groups):
        form_data = {'content': 'This is a message', 'recipient_group': '1', }
        form = SendRecipientGroupForm(data=form_data)
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
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_content(self, groups):
        """Test empty content"""
        form_data = {'content': '', 'recipient_group': '1', }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_group(self):
        """Test empty group"""
        form_data = {'content': 'Hi!', 'recipient_group': '', }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_illegal_chars(self, groups):
        """Test illegal (non-GSM) characters"""
        form_data = {'content': u"This should not pass…", 'recipient': ['1'], }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_max_length(self, groups):
        """Test message far too long"""
        form_data = {'content': 50 * "test", 'recipient': ['1'], }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False

    def test_archived(self, groups):
        """Test archived group"""
        form_data = {'content': 'This is a message', 'recipient_group': '2', }
        form = SendRecipientGroupForm(data=form_data)
        assert form.is_valid() is False
