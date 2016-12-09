from django import template
from django.urls import reverse
from django.utils.safestring import mark_safe

register = template.Library()


@register.simple_tag
def fab_button(href, text, icon_name):
    """Output a formatted fab link"""
    result = '''
    <a class="hvr-backward item" href="{href}">
	<i class="large {icon_name} icon"></i>
	<div class="content"><div class="header">{text}</div>
	</div>
    </a>
    '''.format(
        href=href,
        text=text,
        icon_name=icon_name,
    )
    return mark_safe(result)


# Contacts


@register.simple_tag
def fab_new_contact():
    return fab_button(reverse('recipient'), 'New Contact', 'plus')


@register.simple_tag
def fab_contacts_archive():
    return fab_button(
        reverse('recipients_archive'), 'Archived Contacts', 'table'
    )


# Groups


@register.simple_tag
def fab_new_group():
    return fab_button(reverse('group'), 'New Group', 'plus')


@register.simple_tag
def fab_groups_archive():
    return fab_button(
        reverse('recipient_groups_archive'), 'Archived Groups', 'table'
    )


@register.simple_tag
def fab_groups():
    return fab_button(reverse('recipient_groups'), 'Groups', 'table')


# Incoming SMS


@register.simple_tag
def fab_incoming_wall():
    return fab_button(reverse('incoming_wall'), 'Live Updates', 'inbox')


@register.simple_tag
def fab_incoming_wall_curator():
    return fab_button(
        reverse('incoming_wall_curator'), 'Live Curator', 'table'
    )


# Keywords


@register.simple_tag
def fab_new_keyword():
    return fab_button(reverse('keyword'), 'New Keyword', 'plus')


@register.simple_tag
def fab_keywords():
    return fab_button(reverse('keywords'), 'Keywords', 'table')


@register.simple_tag
def fab_keywords_archive():
    return fab_button(
        reverse('keywords_archive'), 'Archived Keywords', 'table'
    )


@register.simple_tag
def fab_keyword_csv(keyword):
    return fab_button(
        reverse(
            'keyword_csv', args=[keyword.pk]
        ),
        'Export {k} responses'.format(k=keyword.keyword),
        'download'
    )


@register.simple_tag
def fab_keyword_edit(keyword):
    return fab_button(reverse('keyword', args=[keyword.pk]), 'Edit', 'edit')


@register.simple_tag
def fab_keyword_responses(keyword):
    return fab_button(
        reverse(
            'keyword_responses', args=[keyword.pk]
        ),
        'Replies ({n})'.format(n=keyword.num_matches),
        'inbox'
    )


@register.simple_tag
def fab_keyword_responses_archive(keyword):
    return fab_button(
        reverse(
            'keyword_responses_archive', args=[keyword.pk]
        ),
        'Archived Replies ({n})'.format(n=keyword.num_archived_matches),
        'inbox'
    )
