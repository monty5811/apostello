from django import forms

from site_config.models import DefaultResponses, SiteConfiguration


class SiteConfigurationForm(forms.ModelForm):
    """Site configuration model form."""

    class Meta:
        model = SiteConfiguration
        exclude = []


class DefaultResponsesForm(forms.ModelForm):
    """Default responses model form."""

    class Meta:
        model = DefaultResponses
        exclude = []
