from django import forms

from site_config.models import DefaultResponses, SiteConfiguration


class SiteConfigurationForm(forms.ModelForm):
    """Site configuration model form."""
    sms_expiration_date = forms.DateField(
        input_formats=('%Y-%m-%d', ),
        required=False,
        label='SMS Expiration Date',
        help_text='If this date is set, any messages older than this will be'
        ' removed from the database.'
    )

    class Meta:
        model = SiteConfiguration
        exclude = []

    def clean(self):
        cleaned_data = super(SiteConfigurationForm, self).clean()
        fields_to_blank = [
            'email_from',
            'email_host',
            'email_password',
            'email_port',
            'email_username',
            'twilio_account_sid',
            'twilio_auth_token',
            'twilio_from_num',
            'twilio_sending_cost',
        ]
        for field in fields_to_blank:
            try:
                if not cleaned_data[field]:
                    cleaned_data[field] = None
            except KeyError:
                pass


class DefaultResponsesForm(forms.ModelForm):
    """Default responses model form."""

    class Meta:
        model = DefaultResponses
        exclude = []
