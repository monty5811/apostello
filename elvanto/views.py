from django.contrib.auth.mixins import LoginRequiredMixin

from apostello.mixins import ProfilePermsMixin
from apostello.utils import ApTemplateView as TemplateView


class ImportView(LoginRequiredMixin, ProfilePermsMixin, TemplateView):
    """Display the Elvanto import form."""
    required_perms = []
    template_name = 'elvanto/import.html'
