from datetime import timedelta
import logging

from django.core.exceptions import ValidationError
from django.utils import timezone

from apostello.models import Keyword, Recipient
from apostello.utils import fetch_default_reply
from django_q.models import Schedule
from django_q.tasks import async, schedule

logger = logging.getLogger('apostello')


class InboundSms:
    """Handle incoming messages."""

    def lookup_contact(self):
        """
        Find Recipient object for the sender of the message and determine if we
        should ask for the contact's name.
        """
        logger.info('Looking contact for %s', self.contact_number)
        try:
            return Recipient.objects.get(number=self.contact_number), False
        except Recipient.DoesNotExist:
            logger.info(
                'Contact (%s) does not exist, creating', self.contact_number
            )
            contact = Recipient.objects.create(
                number=self.contact_number,
                first_name='Unknown',
                last_name='Person'
            )
            contact.save()
            return contact, not self.keyword == "name"

    def start_bg_tasks(self):
        """
        Kick off background tasks for each message.

        Starts tasks to:
            * Log the message in the db
            * Post the message to slack
            * Send blacklist warnings if required
            * Ask the contact for their name if we don't have it
            * Schedules a task to check the outgoing log one minute from now
        """
        async(
            'apostello.tasks.log_msg_in', self.msg_params,
            timezone.now(), self.contact.pk
        )
        async(
            'apostello.tasks.sms_to_slack', self.sms_body,
            str(self.contact), str(self.keyword)
        )
        async(
            'apostello.tasks.blacklist_notify', self.contact.pk, self.sms_body,
            self.keyword
        )
        async(
            'apostello.tasks.ask_for_name', self.contact.pk, self.sms_body,
            self.send_name_sms
        )
        # update outgoing log 1 minute from now:
        schedule(
            'apostello.tasks.check_outgoing_log',
            schedule_type=Schedule.ONCE,
            next_run=timezone.now() + timedelta(minutes=1)
        )

    def reply_to_start(self):
        """Reply to the "start" keyword."""
        self.contact.is_blocking = False
        self.contact.save()
        return fetch_default_reply('start_reply')

    def reply_to_stop(self):
        """Handle the "stop" keyword."""
        logger.info(
            "%s (%s) has black listed us.", self.contact.number,
            self.contact.full_name
        )
        self.contact.is_blocking = True
        self.contact.save()
        return ''

    def reply_to_name(self):
        """Handle the "name" keyword."""
        try:
            # update person's name:
            self.contact.first_name = self.sms_body.split()[1].strip()
            last_name = " ".join(self.sms_body.split()[2:]).strip()
            if not last_name:
                raise ValidationError('No last name')
            last_name = last_name.split('\n')[0]
            last_name = last_name[0:40]  # truncate last name
            self.contact.last_name = last_name
            self.contact.save()
            # update old messages with this person's name
            async('apostello.tasks.update_msgs_name', self.contact.pk)
            # thank person
            async(
                'apostello.tasks.notify_office_mail',
                '[Apostello] New Signup!',
                'SMS:\n\t{0}\nFrom:\n\t{1} ({2})\n'.format(
                    self.sms_body,
                    str(self.contact),
                    self.contact_number,
                ),
            )
            # TODO update to use .format() and add help text to model
            return fetch_default_reply(
                'name_update_reply'
            ) % self.contact.first_name
        except (ValidationError, IndexError):
            async(
                'apostello.tasks.notify_office_mail',
                '[Apostello] New Signup - FAILED!',
                'SMS:\n\t{0}\nFrom:\n\t{1}\n'.format(
                    self.sms_body, self.contact_number
                ),
            )
            return fetch_default_reply('name_failure_reply')

    def construct_reply(self):
        """Construct appropriate reply."""

        if self.contact.do_not_reply:
            return ''

        if self.keyword == "start":
            reply = self.reply_to_start()
        elif self.keyword == "stop":
            reply = self.reply_to_stop()
        elif self.keyword == "name":
            reply = self.reply_to_name()
        else:
            # otherwise construct reply
            try:
                reply = self.keyword.construct_reply(self.contact)
            except AttributeError:
                reply = fetch_default_reply('keyword_no_match')
                reply = self.contact.personalise(reply)

        if self.contact.is_blocking:
            return ''
        else:
            return reply

    def __init__(self, msg_params):
        self.msg_params = msg_params
        self.contact_number = msg_params['From']
        self.sms_body = msg_params['Body'].strip()
        # match keyword:
        self.keyword = Keyword.match(self.sms_body)
        # look up contact and determine if we need to ask for their name:
        self.contact, self.send_name_sms = self.lookup_contact()
        # construct reply sms
        self.reply = self.construct_reply()
        # add contact to keyword linked groups:
        try:
            self.keyword.add_contact_to_groups(self.contact)
        except AttributeError:
            # not a custom keyword
            pass
