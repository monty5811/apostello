from datetime import timedelta
from django.utils import timezone
from django.core.exceptions import ValidationError

from django_q.tasks import async, schedule
from django_q.models import Schedule

from apostello.models import Recipient
from apostello.utils import fetch_default_reply


def keyword_replier(k, person_from):
    """
    Construct reply to message.

    Attempts to use the keyword's reply.
    If not a valid keyword, then the no match reply is used.
    """
    try:
        reply = k.construct_reply(person_from)
    except AttributeError:
        reply = fetch_default_reply('keyword_no_match')
        reply = person_from.personalise(reply)

    return reply


def get_person_or_ask_for_name(from_, sms_body, keyword_obj):
    """
    Return the Recipient object for the sender of the message.

    Perform a look up on the sender of the message.
    If they exist in the system, they are returned.
    Otherwise a message is queued to ask them for their name.
    """
    try:
        person_from = Recipient.objects.get(number=from_)
    except Recipient.DoesNotExist:
        person_from = Recipient.objects.create(
            number=from_,
            first_name='Unknown',
            last_name='Person'
        )
        person_from.save()
        if keyword_obj == "name":
            pass
        else:
            from site_config.models import SiteConfiguration
            config = SiteConfiguration.get_solo()
            if not config.disable_all_replies:
                person_from.send_message(
                    content=fetch_default_reply('auto_name_request'),
                    sent_by="auto name request"
                )
                async(
                    'apostello.tasks.notify_office_mail',
                    '[Apostello] Unknown Contact!',
                    'SMS: {0}\nFrom: {1}\n\n\nThis person is unknown and has been asked for their name.'.format(
                        sms_body, from_
                    ),
                )

    return person_from


def reply_to_incoming(person_from, from_, sms_body, keyword):
    """Construct appropriate reply."""
    # update outgoing log 1 minute from now:
    schedule(
        'apostello.tasks.check_outgoing_log',
        schedule_type=Schedule.ONCE,
        next_run=timezone.now() + timedelta(minutes=1)
    )

    if keyword == "start":
        person_from.is_blocking = False
        person_from.save()
        return fetch_default_reply('start_reply')
    elif keyword == "stop":
        person_from.is_blocking = True
        person_from.save()
        async('apostello.tasks.warn_on_blacklist', person_from.pk)
        return ''
    elif keyword == "name":
        async(
            'apostello.tasks.warn_on_blacklist_receipt', person_from.pk,
            sms_body
        )
        try:
            # update person's name:
            person_from.first_name = sms_body.split()[1].strip()
            person_from.last_name = " ".join(sms_body.split()[2:]).strip()
            if not person_from.last_name:
                raise ValidationError('No last name')
            person_from.save()
            # update old messages with this person's name
            async('apostello.tasks.update_msgs_name', person_from.pk)
            # thank person
            async(
                'apostello.tasks.notify_office_mail',
                '[Apostello] New Signup!',
                'SMS:\n\t{0}\nFrom:\n\t{1}\n'.format(
                    sms_body,
                    from_,
                ),
            )
            # TODO update to use .format() and add help text to model
            return fetch_default_reply(
                'name_update_reply'
            ) % person_from.first_name
        except (ValidationError, IndexError):
            async(
                'apostello.tasks.notify_office_mail',
                '[Apostello] New Signup - FAILED!',
                'SMS:\n\t{0}\nFrom:\n\t{1}\n'.format(
                    sms_body, from_
                ),
            )
            return fetch_default_reply('name_failure_reply')
    else:
        # otherwise construct reply
        async(
            'apostello.tasks.warn_on_blacklist_receipt', person_from.pk,
            sms_body
        )
        return keyword_replier(keyword, person_from)
