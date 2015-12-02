# -*- coding: utf-8 -*-
from datetimewidget.widgets import DateTimeWidget
from django import forms

from apostello.models import Keyword, Recipient, RecipientGroup
from apostello.validators import gsm_validator, less_than_sms_char_limit


class SendAdhocRecipientsForm(forms.Form):
    """
    Sends an sms to ad-hoc groups.
    """
    content = forms.CharField(
        validators=[gsm_validator, less_than_sms_char_limit],
        required=True,
        min_length=1
    )
    recipients = forms.ModelMultipleChoiceField(
        queryset=Recipient.objects.filter(is_archived=False),
        required=True,
        help_text=''
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        widget=DateTimeWidget(bootstrap_version=3, options={'format': 'yyyy-mm-dd hh:ii'}),
        help_text='Leave this blank to send your message immediately, otherwise select a date and time to schedule your message'
    )


class SendRecipientGroupForm(forms.Form):
    """
    Sends an sms to pre-defined group.
    """
    content = forms.CharField(
        validators=[gsm_validator, less_than_sms_char_limit],
        required=True,
        min_length=1
    )
    recipient_group = forms.ModelChoiceField(
        queryset=RecipientGroup.objects.filter(
            is_archived=False
        ),
        required=True,
        empty_label='Choose a group...'
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        widget=DateTimeWidget(bootstrap_version=3, options={'format': 'yyyy-mm-dd hh:ii'}),
        help_text='Leave this blank to send your message immediately, otherwise select a date and time to schedule your message'
    )


class ManageRecipientGroupForm(forms.ModelForm):
    """
    Manages RecipientGroup updates and creation.

    __init__ and save are overridden to pull in group members.
    """

    class Meta:
        model = RecipientGroup
        exclude = ['is_archived']

    # Representing the many to many related field in SmsGroup
    members = forms.ModelMultipleChoiceField(
        queryset=Recipient.objects.filter(
            is_archived=False
        ),
        required=False
    )

    def __init__(self, *args, **kwargs):
        if 'instance' in kwargs:
            # We get the 'initial' keyword argument or initialize it as a dict if it didn't exist.
            initial = kwargs.setdefault('initial', {})
            # The widget for a ModelMultipleChoiceField expects a list of primary key for the selected data.
            initial['members'] = [t.pk for t in kwargs['instance'].recipient_set.all()]

        forms.ModelForm.__init__(self, *args, **kwargs)

    # Overriding save allows us to process the value of 'people' field
    def save(self, *args, **kwargs):
        instance = forms.ModelForm.save(self)
        instance.recipient_set.clear()
        for recipient in self.cleaned_data['members']:
            instance.recipient_set.add(recipient)


class RecipientForm(forms.ModelForm):
    """
    Updates Recipients.
    """

    class Meta:
        model = Recipient
        exclude = ['is_archived', 'is_blocking']
        widgets = {
            'number': forms.TextInput(attrs={'placeholder': '+447259006790'})
        }


class KeywordForm(forms.ModelForm):
    """
    Updates Keywords.
    """

    class Meta:
        model = Keyword
        exclude = ['is_archived', 'last_email_sent_time']
        dt_options = {'format': 'yyyy-mm-dd hh:ii'}
        widgets = {
            'keyword': forms.TextInput(attrs={'placeholder': '(No spaces allowed)'}),
            'description': forms.TextInput(attrs={'placeholder': 'Please provide a description of your keyword.'}),
            'custom_response': forms.TextInput(attrs={'placeholder': 'eg: Thanks %name%, you have sucessfully signed up.'}),
            'deactivate_time': DateTimeWidget(bootstrap_version=3, options=dt_options),
            'activate_time': DateTimeWidget(bootstrap_version=3, options=dt_options)
        }


class ArchiveKeywordResponses(forms.Form):
    """
    Used on keyword log page to allow user to archive all matching messages.

    Single tick-box field for confirmation.
    """
    tick_to_archive_all_responses = forms.BooleanField()


class CsvImport(forms.Form):
    """
    Handles CSV imports.
    """
    csv_data = forms.CharField(
        help_text='John, Calvin, +447095237960',
        widget=forms.Textarea
    )
