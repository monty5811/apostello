from django.template.response import TemplateResponse
from django.views.decorators.cache import never_cache
from django.views.generic import TemplateView

from site_config.models import SiteConfiguration


@never_cache
def sw_js(request, js):
    return TemplateResponse(request, "apostello/sw.js", content_type="application/x-javascript")


class NotApprovedView(TemplateView):
    """Simple view that presents the not approved page."""

    template_name = "apostello/not_approved.html"

    def get_context_data(self, **kwargs):
        """Inject not approved message into context."""
        context = super(NotApprovedView, self).get_context_data(**kwargs)
        s = SiteConfiguration.get_solo()
        context["msg"] = s.not_approved_msg
        return context
