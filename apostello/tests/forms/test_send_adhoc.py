# -*- coding: utf-8 -*-
import pytest

from apostello.forms import SendAdhocRecipientsForm


@pytest.mark.parametrize(
    "form_content,form_recipients", [
        ('This is a message', ['1']),
        ('This is a message', ['1', '2']),
    ]
)
@pytest.mark.django_db
class TestAdhocFormValid():
    """Tests apostello.forms.SendAdhocRecipientsForm"""

    def test_correct_single(self, form_content, form_recipients, recipients):
        """Tests valid form inputs"""
        form_data = {'content': form_content, 'recipients': form_recipients, }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid()


@pytest.mark.django_db
class TestAdhocFormInvalid():
    """Tests apostello.forms.SendAdhocRecipientsForm"""

    def test_missing_person(self):
        """Test no person supplied"""
        form_data = {'content': 'This is a message', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_missing_content(self, recipients):
        """Test no content supplied"""
        form_data = {'recipient': '1', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_content(self, recipients):
        """Test empty message"""
        form_data = {'content': '', 'recipient': '1', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_empty_person(self):
        """Test no recipients"""
        form_data = {'content': 'Hi!', 'recipient': '', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_max_length(self, recipients):
        """Test message far too long"""
        form_data = {'content': 50 * "test", 'recipient': '1', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False

    def test_illegal_chars(self, recipients):
        """Test illegal (non-GSM) characters"""
        form_data = {'content': u"This should not pass…", 'recipient': '1', }
        form = SendAdhocRecipientsForm(data=form_data)
        assert form.is_valid() is False
