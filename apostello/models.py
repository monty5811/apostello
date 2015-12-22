# -*- coding: utf-8 -*-
import hashlib

from django.conf import settings
from django.contrib.auth.models import User
from django.core.cache import cache
from django.core.cache.utils import make_template_fragment_key
from django.core.exceptions import ValidationError
from django.core.urlresolvers import reverse
from django.db import models
from django.utils import timezone
from django.utils.functional import cached_property
from phonenumber_field.modelfields import PhoneNumberField
from solo.models import SingletonModel

from apostello.elvanto import elvanto, try_both_num_fields
from apostello.exceptions import (ElvantoException, NoKeywordMatchException,
                                  NotValidPhoneNumber)
from apostello.tasks import (group_send_message_task,
                             recipient_send_message_task)
from apostello.utils import fetch_default_reply
from apostello.validators import (TWILIO_INFO_WORDS, TWILIO_START_WORDS,
                                  TWILIO_STOP_WORDS, gsm_validator,
                                  less_than_sms_char_limit, no_overlap_keyword,
                                  not_twilio_num, twilio_reserved,
                                  validate_lower)


class RecipientGroup(models.Model):
    """Stores groups of recipients."""
    is_archived = models.BooleanField("Archived", default=False)
    name = models.CharField(
        "Name of group",
        max_length=30,
        unique=True,
        validators=[gsm_validator],
    )
    description = models.CharField(
        "Group description",
        max_length=200,
    )

    def send_message(self, content, sent_by, eta=None):
        """Send message to group."""
        group_send_message_task.delay(content, self.name, sent_by, eta)

    def archive(self):
        """Archive the group."""
        self.is_archived = True
        self.save()

    @property
    def all_recipients_names(self):
        """List of the names of recipients."""
        return [str(x) for x in self.recipient_set.all()]

    def calculate_cost(self):
        """Calculate the cost of sending to this group."""
        return settings.SENDING_COST * self.recipient_set.all().count()

    @cached_property
    def get_absolute_url(self):
        """Url for this group."""
        return reverse('group', args=[str(self.pk)])

    @cached_property
    def get_api_url(self):
        """Url for group list api end point."""
        return reverse('api:group', args=[str(self.pk)])

    @cached_property
    def get_table_url(self):
        """Url for group list page."""
        return reverse('recipient_groups')

    def __str__(self):
        """Pretty representation."""
        return self.name

    class Meta:
        ordering = ['name']


class ElvantoGroup(models.Model):
    """Stores details of Elvanto Groups."""
    sync = models.BooleanField("Automatic Sync", default=False)
    name = models.CharField("Group Name", max_length=255)
    e_id = models.CharField("Elvanto ID", max_length=36, unique=True)
    last_synced = models.DateTimeField(blank=True, null=True)

    def create_apostello_group(self):
        """
        Return the internal apostello group.

        Creates it if it does not already exist.
        """
        grp = RecipientGroup.objects.get_or_create(name=self.apostello_group_name)[0]
        grp.description = 'Imported from Elvanto'
        grp.save()
        return grp

    def pull(self):
        """Pull group from Elvanto into related apostello group."""
        apostello_group = self.create_apostello_group()
        e_api = elvanto()
        data = e_api._Post("groups/getInfo", id=self.e_id, fields=['people'])
        if data['status'] != 'ok':
            raise ElvantoException

        if data['group'][0]['people']:
            for prsn in data['group'][0]['people']['person']:
                ElvantoGroup.add_person(apostello_group, prsn)

        apostello_group.save()
        self.last_synced = timezone.now()
        self.save()

    @staticmethod
    def add_person(grp, prsn):
        """Add person to group (and apostello if required)."""
        try:
            number = try_both_num_fields(prsn['mobile'], prsn['phone'])
        except NotValidPhoneNumber:
            print('Adding {0} {1} failed'.format(prsn['firstname'], prsn['lastname']))
            return
        # create person
        prsn_obj = Recipient.objects.get_or_create(number=number)[0]
        prsn_obj.first_name = prsn['firstname'] if not prsn['preferred_name'] else prsn['preferred_name']
        prsn_obj.last_name = prsn['lastname']
        prsn_obj.save()
        # add person to group
        grp.recipient_set.add(prsn_obj)

    @staticmethod
    def fetch_all_groups():
        """Pull all group names and ids from Elvanto."""
        e_api = elvanto()
        data = e_api._Post("groups/getAll")
        if data['status'] != 'ok':
            raise ElvantoException

        for grp in data['groups']['group']:
            grp_obj = ElvantoGroup.objects.get_or_create(e_id=grp['id'])[0]
            grp_obj.name = grp['name']
            grp_obj.save()

    @staticmethod
    def pull_all_groups():
        """Pull people from groups and updates the related apostello group."""
        for grp in ElvantoGroup.objects.all():
            if grp.sync:
                try:
                    grp.pull()
                except ElvantoException:
                    # TODO add loggin
                    pass

    @property
    def apostello_group_name(self):
        """
        Name of internal group.

        Just preprend an [E] before the group name.
        """
        return '[E] {0}'.format(self.name)

    def __str__(self):
        """Pretty representation."""
        return self.apostello_group_name


class Recipient(models.Model):
    """Stores the name and number of recipients."""
    is_archived = models.BooleanField("Archived", default=False)
    is_blocking = models.BooleanField(
        "Blocking",
        default=False,
        help_text="If our number has received on of Twilio's stop words, we are now blocked."
    )
    first_name = models.CharField(
        "First Name",
        max_length=settings.MAX_NAME_LENGTH,
        validators=[gsm_validator],
    )
    last_name = models.CharField(
        "Last Name",
        max_length=40,
        validators=[gsm_validator],
    )
    number = PhoneNumberField(
        unique=True,
        validators=[not_twilio_num],
        help_text="Cannot be our number, or we get an SMS loop."
    )
    groups = models.ManyToManyField(RecipientGroup, blank=True)

    def personalise(self, message):
        """
        Personalise outgoing message.

        Any occurence of "%name%" will be replaced with the Recipient's first
        name.
        """
        return message.replace('%name%', self.first_name)

    def send_message(self, content='test message', group=None, sent_by='', eta=None):
        """
        Send SMS to an individual.

        If the person is blocking us, we skip them.
        """
        if self.is_blocking:
            return
        elif eta is None:
            recipient_send_message_task.delay(
                self.pk,
                content,
                group,
                sent_by
            )
        else:
            recipient_send_message_task.apply_async(
                args=[self.pk, content, group, sent_by],
                eta=eta
            )

    def archive(self):
        """Archive the recipient and removes it from groups."""
        self.is_archived = True
        self.groups.clear()
        self.save()

    @cached_property
    def get_absolute_url(self):
        """Url for this recipient."""
        return reverse('recipient', args=[str(self.pk)])

    @cached_property
    def get_api_url(self):
        """Url for recipient list api end point."""
        return reverse('api:recipient', args=[str(self.pk)])

    @cached_property
    def get_table_url(self):
        """Url for recipient list page."""
        return reverse('recipients')

    @cached_property
    def full_name(self):
        """Recipient's full name."""
        return u"{fn} {ln}".format(
            fn=self.first_name,
            ln=self.last_name
        )

    def __str__(self):
        """Pretty representation."""
        return self.full_name

    class Meta:
        ordering = ['last_name', 'first_name']


class Keyword(models.Model):
    """Stores a keyword with its related data."""
    is_archived = models.BooleanField("Archived", default=False)
    keyword = models.SlugField(
        "Keyword",
        max_length=12,
        unique=True,
        validators=[validate_lower,
                    gsm_validator,
                    twilio_reserved,
                    no_overlap_keyword]
    )
    description = models.CharField(
        "Keyword Description",
        max_length=200,
    )
    custom_response = models.CharField(
        "Auto response",
        max_length=100,
        blank=True,
        validators=[gsm_validator, less_than_sms_char_limit],
        help_text='This text will be sent back as a reply when any incoming message matches this keyword. If empty, the site wide response will be used.'
    )
    deactivated_response = models.CharField(
        "Deactivated response",
        max_length=100,
        blank=True,
        validators=[gsm_validator, less_than_sms_char_limit],
        help_text="Use this if you want a custom response after deactivation. e.g. 'You are too late for this event, sorry!'"
    )
    too_early_response = models.CharField(
        "Not yet activated response",
        max_length=1000,
        blank=True,
        validators=[gsm_validator, less_than_sms_char_limit],
        help_text="Use this if you want a custom response before. e.g. 'You are too early for this event, please try agian on Monday!'"
    )
    activate_time = models.DateTimeField(
        "Activation Time",
        default=timezone.now,
        help_text='The keyword will not be active before this time and so no messages will be able to match it. Leave blank to activate now.'
    )
    deactivate_time = models.DateTimeField(
        "Deactivation Time",
        blank=True,
        null=True,
        help_text='The keyword will not be active after this time and so no messages will be able to match it. Leave blank to never deactivate.'
    )
    owners = models.ManyToManyField(
        User,
        blank=True,
        verbose_name='Limit viewing to only these people',
        help_text='If this field is empty, any user can see this keyword. If populated, then only the named users and staff will have access.'
    )
    subscribed_to_digest = models.ManyToManyField(
        User,
        blank=True,
        verbose_name='Subscribed to daily emails.',
        related_name='subscribers',
        help_text='Choose users that will receive daily updates of matched messages.'
    )
    last_email_sent_time = models.DateTimeField(
        "Time of last sent email",
        blank=True,
        null=True
    )

    def construct_reply(self, sender):
        """Make reply to an incoming message."""
        # check if keyword is active
        if not self.is_live:
            if self.deactivated_response != '' and timezone.now() > self.deactivate_time:
                reply = sender.personalise(self.deactivated_response)
            elif self.too_early_response != '' and timezone.now() < self.activate_time:
                reply = sender.personalise(self.too_early_response)
            else:
                reply = sender.personalise(fetch_default_reply('default_no_keyword_not_live')).replace("%keyword%", self.keyword)
        else:
            # keyword is active
            if self.custom_response == '':
                # no custom response, use generic form
                reply = sender.personalise(fetch_default_reply('default_no_keyword_auto_reply'))
            else:
                # use custom response
                reply = sender.personalise(self.custom_response)

        return reply

    @property
    def is_live(self):
        """Is keyword active."""
        started = timezone.now() > self.activate_time
        if self.deactivate_time is None:
            not_ended = True
        else:
            not_ended = timezone.now() < self.deactivate_time
        return started and not_ended

    def fetch_matches(self):
        """Fetch un-archived messages that match keyword."""
        return SmsInbound.objects.filter(
            matched_keyword=self.keyword,
            is_archived=False
        )

    def fetch_archived_matches(self):
        """Fetch archived messages that match keyword."""
        return SmsInbound.objects.filter(
            matched_keyword=self.keyword,
            is_archived=True
        )

    @property
    def num_matches(self):
        """Fetch number of un-archived messages that match keyword."""
        return self.fetch_matches().count()

    @property
    def num_archived_matches(self):
        """Fetch number of archived messages that match keyword."""
        return self.fetch_archived_matches().count()

    @property
    def is_locked(self):
        """Is keyword is locked."""
        if self.owners.all().count() > 0:
            return True
        else:
            return False

    def can_user_access(self, user):
        """Check if user is allowed to access this keyword."""
        if user in self.owners.all():
            return True
        elif user.is_staff:
            return True
        else:
            return False

    def archive(self):
        """Archive this keyword and all matches."""
        self.is_archived = True
        self.save()
        for sms in self.fetch_matches():
            sms.archive()

    def clean(self):
        """Ensure we do not start before we finish."""
        if self.deactivate_time is None:
            return
        if self.activate_time > self.deactivate_time:
            raise ValidationError("The start time must be before the end time!")

    def save(self, force_insert=False, force_update=False, *args, **kwargs):
        """Force lower case keywords."""
        self.keyword = self.keyword.lower()
        super(Keyword, self).save(force_insert, force_update, *args, **kwargs)

    @cached_property
    def get_absolute_url(self):
        """Url for this group."""
        return reverse('keyword', kwargs={'pk': str(self.pk)})

    @cached_property
    def get_api_url(self):
        """Url for keyword list api end point."""
        return reverse('api:keyword', args=[str(self.pk)])

    @cached_property
    def get_table_url(self):
        """Url for keyword list page."""
        return reverse('keywords')

    @cached_property
    def get_responses_url(self):
        """Url for keyword responses list page."""
        return reverse('keyword_responses', args=[str(self.pk)])

    @staticmethod
    def _match(sms):
        """Match keyword or raises exception."""
        if sms == "":
            raise NoKeywordMatchException
        if sms.lower().strip().startswith(TWILIO_STOP_WORDS):
            return 'stop'
        elif sms.lower().strip().startswith(TWILIO_START_WORDS):
            return 'start'
        elif sms.lower().strip().startswith(TWILIO_INFO_WORDS):
            return 'info'
        elif sms.lower().strip().startswith('name'):
            return 'name'

        for keyword in Keyword.objects.all():
            if sms.lower().startswith(str(keyword)):
                query_keyword = keyword
                # return <Keyword object>
                return query_keyword
        else:
            raise NoKeywordMatchException

    @staticmethod
    def match(sms):
        """Match keyword at start of sms."""
        try:
            return Keyword._match(sms)
        except NoKeywordMatchException:
            return 'No Match'

    @staticmethod
    def lookup_colour(sms):
        """Generate. colour for sms table."""
        keyword = Keyword.match(sms)

        if keyword == 'stop':
            return "#FFCDD2"
        elif keyword == 'name':
            return "#BBDEFB"
        elif keyword == 'No Match':
            return "#B6B6B6"
        else:
            return "#" + hashlib.md5(str(keyword).encode('utf-8')).hexdigest()[:6]

    @staticmethod
    def get_log_link(k):
        """Retreive link to keyword log.

        Static method as it may also be called with a "No Match" string.
        """
        try:
            return k.get_responses_url
        except AttributeError:
            return '#'

    def __str__(self):
        """Pretty representation."""
        return self.keyword

    class Meta:
        ordering = ['keyword']


class SmsInbound(models.Model):
    """A SmsInbound is a message that was sent to the twilio number."""
    sid = models.CharField(
        "SID",
        max_length=34,
        unique=True,
        help_text="Twilio's unique ID for this SMS"
    )
    is_archived = models.BooleanField("Is Archived", default=False)
    dealt_with = models.BooleanField(
        "Dealt With?",
        default=False,
        help_text='Used, for example, to mark people as registered for an event.'
    )
    content = models.CharField("Message body", blank=True, max_length=1600)
    time_received = models.DateTimeField(blank=True, null=True)
    sender_name = models.CharField("Sent by", max_length=200)
    sender_num = models.CharField("Sent from", max_length=200)
    matched_keyword = models.CharField(max_length=12)
    matched_colour = models.CharField(max_length=7)
    matched_link = models.CharField(max_length=200)
    display_on_wall = models.BooleanField(
        "Display on Wall?",
        default=False,
        help_text='If True, SMS will be shown on all live walls.'
    )

    def archive(self):
        """Archive the SMS."""
        self.is_archived = True
        self.display_on_wall = False
        self.save()

    def __str__(self):
        """Pretty representation."""
        return self.content

    @cached_property
    def sender_url(self):
        """Url for message sender."""
        return Recipient.objects.get(number=self.sender_num).get_absolute_url

    def reimport(self):
        """
        Manual retrieval of a message from twilio in case of server downtime.

        Note that the message will not be replied to.
        """
        matched_keyword = Keyword.match(self.content.strip())
        self.matched_keyword = str(matched_keyword)
        self.matched_colour = Keyword.lookup_colour(self.content.strip())
        self.matched_link = Keyword.get_log_link(matched_keyword)
        self.is_archived = False
        self.dealt_with = False
        self.save()

    def save(self, *args, **kwargs):
        """Override save method to invalidate cache."""
        super(SmsInbound, self).save(*args, **kwargs)
        cache.set('live_wall', None, 0)

    class Meta:
        ordering = ['-time_received']


class SmsOutbound(models.Model):
    """An SmsOutbound is an SMS that has been sent out by the app."""
    sid = models.CharField(
        "SID",
        max_length=34,
        unique=True,
        help_text="Twilio's unique ID for this SMS"
    )
    content = models.CharField(
        "Message",
        max_length=1600,
        validators=[gsm_validator],
    )
    time_sent = models.DateTimeField(default=timezone.now)
    sent_by = models.CharField(
        "Sender",
        max_length=200,
        help_text='User that sent message. Stored for auditing purposes.'
    )
    recipient_group = models.ForeignKey(
        RecipientGroup,
        null=True,
        blank=True,
        help_text="Group (if any) that message was sent to"
    )
    recipient = models.ForeignKey(
        Recipient,
        blank=True,
        null=True
    )

    def __str__(self):
        """Pretty representation."""
        return self.content

    @cached_property
    def recipient_url(self):
        """Url for message recipient."""
        return self.recipient.get_absolute_url

    class Meta:
        ordering = ['-time_sent']


class SiteConfiguration(SingletonModel):
    """
    Stores site wide configuration options.

    This is a singleton object, there should only be a single instance
    of this model.
    """
    site_name = models.CharField(
        max_length=255,
        default='apostello'
    )
    sms_char_limit = models.PositiveSmallIntegerField(
        default=160,
        help_text='SMS length limit.'
    )
    disable_all_replies = models.BooleanField(
        default=False,
        help_text='Tick this box to disable all automated replies'
    )
    office_email = models.EmailField(
        blank=True,
        help_text='Email to send information emails to'
    )
    from_email = models.EmailField(
        blank=True,
        help_text='Email to send emails from'
    )
    slack_url = models.URLField(
        blank=True,
        help_text='Post all incoming messages to this slack hook. Leave blank to disable.'
    )
    sync_elvanto = models.BooleanField(
        default=False,
        help_text='Toggle automatic syncing of Elvanto groups. Sync will be done overnight',
    )

    def __str__(self):
        """Pretty representation."""
        return u"Site Configuration"

    class Meta:
        verbose_name = "Site Configuration"


class DefaultResponses(SingletonModel):
    """
    Stores the site wide default responses.

    This is a singleton object, there should only be a single instance
    of this model.
    """
    default_no_keyword_auto_reply = models.TextField(
        max_length=1000,
        default='Thank you, %name%, your message has been received.',
        validators=[less_than_sms_char_limit],
        help_text='This message will be sent when a SMS matched a keyword, but that keyword has no reply set'
    )
    default_no_keyword_not_live = models.TextField(
        max_length=1000,
        default='Thank you, %name%, for your text. But "%keyword%" is not active..',
        validators=[less_than_sms_char_limit],
        help_text='Default message for when a keyword is not currently active.'
    )
    keyword_no_match = models.TextField(
        max_length=1000,
        default='Thank you, %name%, your message has not matched any of our keywords. Please correct your message and try again.',
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when an SMS does not match any keywords'
    )
    start_reply = models.TextField(
        max_length=1000,
        default="Thanks for signing up!",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "start"'
    )
    name_update_reply = models.TextField(
        max_length=1000,
        default="Thanks %s!",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "name".'
    )
    name_failure_reply = models.TextField(
        max_length=1000,
        default="Something went wrong, sorry, please try again with the format 'name John Smith'.",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "name" with bad formatting.'
    )
    auto_name_request = models.TextField(
        max_length=1000,
        default="Hi there, I'm afraid we currently don't have your number in our address book. Could you please reply in the format\n'name John Smith'",
        validators=[less_than_sms_char_limit],
        help_text='Message to send when we first receive a message from someone not in the contacts list.'
    )

    def __str__(self):
        """Pretty representation."""
        return u"Default Responses"

    class Meta:
        verbose_name = "Default Responses"


class UserProfile(models.Model):
    """
    Stores permissions related to a User.

    The default profile is created on first access to user.profile.
    """
    user = models.OneToOneField(User, unique=True)

    approved = models.BooleanField(
        default=False,
        help_text='This must be true to grant users access to the site.'
    )

    can_see_groups = models.BooleanField(default=True)
    can_see_contact_names = models.BooleanField(default=True)
    can_see_keywords = models.BooleanField(default=True)
    can_see_outgoing = models.BooleanField(default=True)
    can_see_incoming = models.BooleanField(default=True)

    can_send_sms = models.BooleanField(default=False)
    can_see_contact_nums = models.BooleanField(default=False)
    can_import = models.BooleanField(default=False)

    def __str__(self):
        """Pretty representation."""
        return "Profile: " + str(self.user)

    def save(self, *args, **kwargs):
        """Override save method to set approved status and invalidate navbar cache."""
        if self.pk is None:
            # on first save, approve whitelisted domains
            try:
                email = self.user.email
                email_domain = email.split('@')[1]
                safe_domains = settings.WHITELISTED_LOGIN_DOMAINS
                if email_domain in safe_domains:
                    self.approved = True
            except IndexError:
                # no email adress, leave as unapproved
                pass
        else:
            # any other save, we want to refresh navbar:
            key = make_template_fragment_key('navbar', [self.user])
            cache.delete(key)
        super(UserProfile, self).save(*args, **kwargs)


User.profile = property(lambda u: UserProfile.objects.get_or_create(user=u)[0])
