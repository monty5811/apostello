from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.edit import UpdateView

from apostello.mixins import ProfilePermsMixin
from site_config.models import DefaultResponses, SiteConfiguration
from site_config.forms import DefaultResponsesForm, SiteConfigurationForm


class SiteConfigView(LoginRequiredMixin, ProfilePermsMixin, UpdateView):
    template_name = 'site_config/edit_config.html'
    form_class = SiteConfigurationForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        return SiteConfiguration.get_solo()

    def get_context_data(self, **kwargs):
        context = super(SiteConfigView, self).get_context_data(**kwargs)
        context['hide_menu'] = True
        return context

    def form_valid(self, form):
        messages.success(self.request, 'Configuration updated')
        return super(SiteConfigView, self).form_valid(form)


class ResponsesView(LoginRequiredMixin, ProfilePermsMixin, UpdateView):
    template_name = 'site_config/edit_responses.html'
    form_class = DefaultResponsesForm
    required_perms = []
    success_url = '/'

    def get_object(self):
        return DefaultResponses.get_solo()

    def get_context_data(self, **kwargs):
        context = super(ResponsesView, self).get_context_data(**kwargs)
        context['hide_menu'] = True
        return context

    def form_valid(self, form):
        messages.success(self.request, 'Responses updated')
        return super(ResponsesView, self).form_valid(form)
