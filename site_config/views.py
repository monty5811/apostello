from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.edit import UpdateView

from apostello.mixins import ProfilePermsMixin
from site_config.models import DefaultResponses, SiteConfiguration
from site_config.forms import DefaultResponsesForm, SiteConfigurationForm


class SiteConfigView(LoginRequiredMixin, ProfilePermsMixin, UpdateView):
    """View to handle site config form."""
    template_name = 'site_config/edit_config.html'
    form_class = SiteConfigurationForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        """Retreive the config instance."""
        return SiteConfiguration.get_solo()

    def form_valid(self, form):
        """Handle successful form submission."""
        messages.success(self.request, 'Configuration updated')
        return super(SiteConfigView, self).form_valid(form)


class ResponsesView(LoginRequiredMixin, ProfilePermsMixin, UpdateView):
    """View to handle default responses form."""
    template_name = 'site_config/edit_responses.html'
    form_class = DefaultResponsesForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        """Retreive the config instance."""
        return DefaultResponses.get_solo()

    def form_valid(self, form):
        """Handle successful form submission."""
        messages.success(self.request, 'Responses updated')
        return super(ResponsesView, self).form_valid(form)
