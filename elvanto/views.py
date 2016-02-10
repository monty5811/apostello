from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import TemplateView

from apostello.mixins import ProfilePermsMixin


class ImportView(LoginRequiredMixin, ProfilePermsMixin, TemplateView):
    """Display the Elvanto import form."""
    required_perms = []
    template_name = 'elvanto/import.html'
