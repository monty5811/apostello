# -*- coding: utf-8 -*-
import pygal
from django.http import HttpResponse
from django.utils import timezone
from pygal.style import CleanStyle

from .sms_freq import sms_graph_data


def recent(request):
    """Display the recent SMS activity graph on home page."""
    bar_chart = pygal.Bar(height=200,
                          style=CleanStyle,
                          margin=15,
                          spacing=5,
                          show_y_labels=True,
                          x_label_rotation=90,
                          legend_box_size=10
                          )
    bar_chart.add('In', sms_graph_data(direction='in'))
    bar_chart.add('Out', sms_graph_data(direction='out'))
    td = timezone.now()
    xlabels = []
    for x in range(-30, 1):
        delta = timezone.timedelta(days=x)
        today = td + delta
        xlabels.append(today.strftime('%d %b'))
    bar_chart.x_labels = xlabels
    return HttpResponse(bar_chart.render(), content_type='image/svg+xml')
