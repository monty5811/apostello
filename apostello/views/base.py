from django.template.response import TemplateResponse
from django.views.generic import View

from apostello.mixins import ProfilePermsMixin


class SimpleView(ProfilePermsMixin, View):
    """Simple view that can ensure user is logged in and has permissions."""
    template_name = ''
    required_perms = []

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        return TemplateResponse(request, self.template_name, {})
