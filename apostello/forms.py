from django import forms
from django.forms import ModelMultipleChoiceField

from apostello.models import Keyword, Recipient, RecipientGroup, UserProfile
from apostello.validators import gsm_validator, less_than_sms_char_limit


class SendAdhocRecipientsForm(forms.Form):
    """Send an sms to ad-hoc groups."""
    content = forms.CharField(
        validators=[gsm_validator, less_than_sms_char_limit],
        required=True,
        min_length=1
    )
    recipients = forms.ModelMultipleChoiceField(
        queryset=Recipient.objects.filter(is_archived=False),
        required=True,
        help_text='',
        widget=forms.SelectMultiple(
            attrs={
                "class": "ui compact search dropdown",
                "multiple": "",
            }
        ),
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        help_text='Leave this blank to send your message immediately, '
        'otherwise select a date and time to schedule your message',
        widget=forms.TextInput(
            attrs={
                'data-field': 'datetime',
                'readonly': True,
            },
        ),
    )

    def clean(self):
        cleaned_data = super(SendAdhocRecipientsForm, self).clean()
        if 'recipients' in cleaned_data and 'content' in cleaned_data:
            # if we have no recipients, we don't need to check cost limit
            Recipient.check_user_cost_limit(
                cleaned_data['recipients'],
                self.user.profile.message_cost_limit, cleaned_data['content']
            )

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        super(SendAdhocRecipientsForm, self).__init__(*args, **kwargs)


class SendRecipientGroupForm(forms.Form):
    """Send an sms to pre-defined group."""
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
        empty_label='Choose a group...',
        widget=forms.Select(
            attrs={
                "class": "ui fluid dropdown",
                "id": "id_recipient_group",
            }
        ),
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        help_text='Leave this blank to send your message immediately, '
        'otherwise select a date and time to schedule your message',
        widget=forms.TextInput(
            attrs={
                'data-field': 'datetime',
                'readonly': True,
            },
        ),
    )

    def clean(self):
        cleaned_data = super(SendRecipientGroupForm, self).clean()
        if 'recipient_group' in cleaned_data and 'content' in cleaned_data:
            # if we have no recipient group, we don't need to check cost limit
            cleaned_data['recipient_group'].check_user_cost_limit(
                self.user.profile.message_cost_limit, cleaned_data['content']
            )

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        super(SendRecipientGroupForm, self).__init__(*args, **kwargs)


class ManageRecipientGroupForm(forms.ModelForm):
    """
    Manage RecipientGroup updates and creation.

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
        required=False,
        widget=forms.SelectMultiple(
            attrs={
                "class": "ui fluid search dropdown",
                "multiple": "",
                "id": "members_dropdown",
            }
        ),
    )

    def __init__(self, *args, **kwargs):
        """Override init method to pull in existing group members."""
        if 'instance' in kwargs:
            initial = kwargs.setdefault('initial', {})
            # The widget for a ModelMultipleChoiceField expects a list of primary key for the selected data.
            initial['members'] = [
                t.pk for t in kwargs['instance'].recipient_set.all()
            ]

        forms.ModelForm.__init__(self, *args, **kwargs)

    def save(self, *args, **kwargs):
        """Override save method to update group members."""
        instance = forms.ModelForm.save(self)
        instance.recipient_set.clear()
        for recipient in self.cleaned_data['members']:
            instance.recipient_set.add(recipient)


class RecipientForm(forms.ModelForm):
    """Handle Recipients."""

    class Meta:
        model = Recipient
        exclude = ['is_archived', 'is_blocking']
        widgets = {
            'number': forms.TextInput(attrs={'placeholder': '+447259006790'}),
            'groups': forms.SelectMultiple(
                attrs={
                    "class": "ui fluid search dropdown",
                    "multiple": "",
                    "id": "groups_dropdown",
                }
            ),
        }


class UserChoiceField(ModelMultipleChoiceField):
    """Display emails and user names when selecting users."""

    def label_from_instance(self, obj):
        """Display the user's label."""
        return '{0} ({1})'.format(obj.email, obj.username)


class KeywordForm(forms.ModelForm):
    """Handle Keywords."""

    class Meta:
        model = Keyword
        exclude = ['is_archived', 'last_email_sent_time']
        field_classes = {
            'subscribed_to_digest': UserChoiceField,
            'owners': UserChoiceField,
        }
        widgets = {
            'keyword':
            forms.TextInput(attrs={'placeholder': '(No spaces allowed)'}),
            'description': forms.TextInput(
                attrs={
                    'placeholder':
                    'Please provide a description of your keyword.'
                }
            ),
            'custom_response': forms.TextInput(
                attrs={
                    'placeholder':
                    'eg: Thanks %name%, you have sucessfully signed up.'
                }
            ),
            'activate_time': forms.TextInput(
                attrs={
                    'data-field': 'datetime',
                    'readonly': True,
                },
            ),
            'deactivate_time': forms.TextInput(
                attrs={
                    'data-field': 'datetime',
                    'readonly': True,
                },
            ),
            'owners': forms.SelectMultiple(
                attrs={
                    "class": "ui fluid search dropdown",
                    "multiple": "",
                    "id": "owners_dropdown",
                }
            ),
            'subscribed_to_digest': forms.SelectMultiple(
                attrs={
                    "class": "ui fluid search dropdown",
                    "multiple": "",
                    "id": "digest_dropdown",
                }
            ),
        }


class ArchiveKeywordResponses(forms.Form):
    """
    Handle archiving all matching messages for a keyword.

    Single tick-box field for confirmation.
    """
    tick_to_archive_all_responses = forms.BooleanField()


class CsvImport(forms.Form):
    """Handle CSV imports."""
    csv_data = forms.CharField(
        help_text='John, Calvin, +447095237960',
        widget=forms.Textarea
    )


class UserProfileForm(forms.ModelForm):
    """Handle User Permission Updates"""

    class Meta:
        model = UserProfile
        exclude = ['user', ]


class GroupAllCreateForm(forms.Form):
    """Form used to create groups with all recipients.
    Should only be used to create, not edit groups.
    """
    group_name = forms.CharField(
        help_text='Name of group.\n'
        'If this group already exists it will be overwritten.',
        max_length=150,
    )
