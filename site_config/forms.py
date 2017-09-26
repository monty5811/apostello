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


class DefaultResponsesForm(forms.ModelForm):
    """Default responses model form."""

    class Meta:
        model = DefaultResponses
        exclude = []
