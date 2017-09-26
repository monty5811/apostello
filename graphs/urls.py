from django.conf.urls import url

from graphs import renderers as r
from graphs import views as v

urlpatterns = [
    url(r'^recent/', v.GraphView.as_view(
        graph_renderer=r.recent,
        required_perms=[],
    )),
    url(r'^contacts/', v.GraphView.as_view(graph_renderer=r.contacts, )),
    url(r'^groups/', v.GraphView.as_view(graph_renderer=r.groups, )),
    url(r'^keywords/', v.GraphView.as_view(graph_renderer=r.keywords, )),
    url(r'^sms/totals/', v.GraphView.as_view(graph_renderer=r.sms_totals, )),
    url(r'^sms/in/bycontact', v.GraphView.as_view(graph_renderer=r.incoming_by_contact, )),
    url(r'^sms/out/bycontact', v.GraphView.as_view(graph_renderer=r.outgoing_by_contact, )),
]
