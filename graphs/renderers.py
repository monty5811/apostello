import pygal
from django.utils import timezone
from pygal.style import CleanStyle

from apostello.models import (
    Keyword, Recipient, RecipientGroup, SmsInbound, SmsOutbound
)
from graphs.sms_freq import sms_graph_data

clean_style_large_text = CleanStyle(legend_font_size=30, tooltip_font_size=30,)


def recent():
    """Render the recent SMS activity graph on home page."""
    bar_chart = pygal.Bar(
        height=200,
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

    return bar_chart.render()


def contacts():
    """Render pie chart for contacts."""
    pie_chart = pygal.Pie(
        inner_radius=.6,
        style=clean_style_large_text,
        margin=0,
        value_formatter=lambda x: '{}'.format(x),
    )
    archived = Recipient.objects.filter(is_archived=True).count()
    blacklisted = Recipient.objects.filter(is_blocking=True).count()
    remaining = Recipient.objects.all().count() - archived - blacklisted

    pie_chart.add('Contacts', remaining)
    pie_chart.add('Archived', archived)
    pie_chart.add('Blacklisted', blacklisted)

    return pie_chart.render(
        legend_box_size=40,
        legend_at_bottom=True,
        legend_at_bottom_columns=3,
    )


def groups():
    """Render tree map of group size."""
    treemap = pygal.Treemap(style=clean_style_large_text, margin=0, )
    for grp in RecipientGroup.objects.filter(is_archived=False):
        treemap.add(str(grp), [grp.recipient_set.all().count()])

    return treemap.render(show_legend=False, )


def keywords():
    """Render pie chart for keywords."""
    pie_chart = pygal.Pie(
        inner_radius=.6,
        style=clean_style_large_text,
        margin=0,
        value_formatter=lambda x: '{}'.format(x),
    )
    for k in Keyword.objects.filter(is_archived=False):
        pie_chart.add(str(k), k.num_matches + k.num_archived_matches)

    return pie_chart.render(
        legend_box_size=40,
        legend_at_bottom=True,
        legend_at_bottom_columns=3,
    )


def incoming_by_contact():
    """Render tree map of incoming messages, grouped by user."""
    treemap = pygal.Treemap(style=clean_style_large_text, margin=0, )
    for con in Recipient.objects.filter(is_archived=False):
        treemap.add(
            str(con),
            SmsInbound.objects.filter(sender_num=str(con.number)).count(),
        )

    return treemap.render(show_legend=False, )


def outgoing_by_contact():
    """Render tree map of outgoing messages, grouped by user."""
    treemap = pygal.Treemap(style=clean_style_large_text, margin=0, )
    for con in Recipient.objects.filter(is_archived=False):
        treemap.add(
            str(con),
            SmsOutbound.objects.filter(recipient=con).count()
        )

    return treemap.render(show_legend=False, )


def sms_totals():
    """Render pie chart for sms totals."""
    pie_chart = pygal.Pie(
        inner_radius=.6,
        style=clean_style_large_text,
        margin=0,
        value_formatter=lambda x: '{}'.format(x),
    )

    pie_chart.add('Sent', SmsOutbound.objects.all().count())
    pie_chart.add('Received', SmsInbound.objects.all().count())

    return pie_chart.render(
        legend_box_size=40,
        legend_at_bottom=True,
        legend_at_bottom_columns=2,
    )
