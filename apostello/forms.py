from django import forms
from django.core.exceptions import ValidationError
from django.forms import ModelMultipleChoiceField

from apostello.models import Keyword, Recipient, RecipientGroup, UserProfile
from apostello.validators import gsm_validator, less_than_sms_char_limit
import allauth.account.forms


class SendAdhocRecipientsForm(forms.Form):
    """Send an sms to ad-hoc groups."""

    content = forms.CharField(validators=[gsm_validator, less_than_sms_char_limit], required=True, min_length=1)
    recipients = forms.ModelMultipleChoiceField(
        queryset=Recipient.objects.filter(is_archived=False), required=True, help_text=""
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        help_text="Leave this blank to send your message immediately, "
        "otherwise select a date and time to schedule your message",
        label="Scheduled Time",
    )

    def clean(self):
        """Override clean method to check SMS cost limit."""
        cleaned_data = super(SendAdhocRecipientsForm, self).clean()
        if "recipients" in cleaned_data and "content" in cleaned_data:
            # if we have no recipients, we don't need to check cost limit
            Recipient.check_user_cost_limit(
                cleaned_data["recipients"], self.user.profile.message_cost_limit, cleaned_data["content"]
            )

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop("user", None)
        super(SendAdhocRecipientsForm, self).__init__(*args, **kwargs)


class SendRecipientGroupForm(forms.Form):
    """Send an sms to pre-defined group."""

    content = forms.CharField(validators=[gsm_validator, less_than_sms_char_limit], required=True, min_length=1)
    recipient_group = forms.ModelChoiceField(
        queryset=RecipientGroup.objects.filter(is_archived=False),
        required=True,
        empty_label="Choose a group...",
        label="Recipient Group",
    )
    scheduled_time = forms.DateTimeField(
        required=False,
        help_text="Leave this blank to send your message immediately, "
        "otherwise select a date and time to schedule your message",
        label="Scheduled Time",
    )

    def clean(self):
        """Override clean method to check SMS cost limit."""
        cleaned_data = super(SendRecipientGroupForm, self).clean()
        if "recipient_group" in cleaned_data and "content" in cleaned_data:
            # if we have no recipient group, we don't need to check cost limit
            cleaned_data["recipient_group"].check_user_cost_limit(
                self.user.profile.message_cost_limit, cleaned_data["content"]
            )

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop("user", None)
        super(SendRecipientGroupForm, self).__init__(*args, **kwargs)


class ManageRecipientGroupForm(forms.ModelForm):
    """
    Manage RecipientGroup updates and creation.

    __init__ and save are overridden to pull in group members.
    """

    class Meta:
        model = RecipientGroup
        exclude = ["is_archived"]


class RecipientForm(forms.ModelForm):
    """Handle Recipients."""

    class Meta:
        model = Recipient
        exclude = ["is_archived", "is_blocking"]

    def _clean_restricted_field(self, field_name, perm_name):
        field = self.fields[field_name]
        initial_field_value = self.get_initial_for_field(field_name=field_name, field=field)

        field_is_present = field_name in self.cleaned_data
        user_has_perm = getattr(self.user.profile, perm_name) or self.user.is_staff
        if field_is_present and (not user_has_perm):
            # trying to set field, but does not have access:
            if field.has_changed(initial=initial_field_value, data=self.cleaned_data[field_name]):
                raise ValidationError(f"You do not have permission to change the {field_name} field.")

        if field_name not in self.cleaned_data:
            # field name is missing, let's use the existing value:
            self.cleaned_data[field_name] = initial_field_value
            if field_name in self.errors:
                del self.errors[field_name]

    def clean(self):
        """Override clean method to check number permission."""
        self.cleaned_data = super(RecipientForm, self).clean()
        self._clean_restricted_field("number", "can_see_contact_nums")
        self._clean_restricted_field("notes", "can_see_contact_notes")

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop("user", None)
        super(RecipientForm, self).__init__(*args, **kwargs)


class KeywordForm(forms.ModelForm):
    """Handle Keywords."""

    class Meta:
        model = Keyword
        exclude = ["is_archived", "last_email_sent_time"]


class CsvImport(forms.Form):
    """Handle CSV imports."""

    csv_data = forms.CharField(help_text="John, Calvin, +447095237960", label="CSV Data")


class UserProfileForm(forms.ModelForm):
    """Handle User Permission Updates"""

    class Meta:
        model = UserProfile
        exclude = ["user", "show_tour"]


class GroupAllCreateForm(forms.Form):
    """Form used to create groups with all recipients.
    Should only be used to create, not edit groups.
    """

    group_name = forms.CharField(
        help_text="Name of group.\n" "If this group already exists it will be overwritten.",
        max_length=150,
        label="Group Name",
    )


class TailwindForm:
    def add_classes(self, skip_fields=["remember"]):
        for field_name in self.fields:
            if field_name not in skip_fields:
                self.fields[field_name].widget.attrs["class"] = "formInput"

        self.label_class = "label"


class LoginForm(allauth.account.forms.LoginForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(LoginForm, self).__init__(*args, **kwargs)
        self.add_classes()


class SignupForm(allauth.account.forms.SignupForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(SignupForm, self).__init__(*args, **kwargs)
        self.add_classes()


class AddEmailForm(allauth.account.forms.AddEmailForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(AddEmailForm, self).__init__(*args, **kwargs)
        self.add_classes()


class ChangePasswordForm(allauth.account.forms.ChangePasswordForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(ChangePasswordForm, self).__init__(*args, **kwargs)
        self.add_classes()


class SetPasswordForm(allauth.account.forms.SetPasswordForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(SetPasswordForm, self).__init__(*args, **kwargs)
        self.add_classes()


class ResetPasswordForm(allauth.account.forms.ResetPasswordForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(ResetPasswordForm, self).__init__(*args, **kwargs)
        self.add_classes()


class ResetPasswordKeyForm(allauth.account.forms.ResetPasswordKeyForm, TailwindForm):
    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop("request", None)
        super(ResetPasswordKeyForm, self).__init__(*args, **kwargs)
        self.add_classes()
