from django.http import HttpResponse

from apostello.views import SimpleView


class GraphView(SimpleView):
    """View to wrap graphs in required permissions."""
    graph_renderer = None

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        return HttpResponse(self.graph_renderer(), content_type='image/svg+xml')
