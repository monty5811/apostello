from django import forms

from site_config.models import DefaultResponses, SiteConfiguration


class SiteConfigurationForm(forms.ModelForm):
    class Meta:
        model = SiteConfiguration
        exclude = []


class DefaultResponsesForm(forms.ModelForm):
    class Meta:
        model = DefaultResponses
        exclude = []
