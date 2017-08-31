from django.contrib.auth.models import User
from django.core.cache import cache
from django.core.cache.utils import make_template_fragment_key
from django.db import models
from solo.models import SingletonModel

from apostello.validators import (less_than_sms_char_limit, validate_starts_with_plus)


class SiteConfiguration(SingletonModel):
    """
    Stores site wide configuration options.

    This is a singleton object, there should only be a single instance
    of this model.
    """
    site_name = models.CharField(max_length=255, default='apostello')
    sms_char_limit = models.PositiveSmallIntegerField(
        default=160,
        help_text='SMS length limit.'
        ' The sending forms use this value to limit the size of messages.'
        ' Check the Twilio pricing docs for pricing information.'
    )
    default_number_prefix = models.CharField(
        max_length=5,
        default='',
        blank=True,
        help_text='This value will be used to prepopulate the new contact form'
        ' use this if you don\'t want to have to type +xx every time.',
        validators=[validate_starts_with_plus]
    )
    disable_all_replies = models.BooleanField(
        default=False, help_text='Tick this box to disable all automated replies.'
    )
    disable_email_login_form = models.BooleanField(
        default=False,
        help_text='Tick this to hide the login with email form.'
        ' Note, you will need to have setup login with Google, or users will'
        ' have no way into the site.'
    )
    office_email = models.EmailField(blank=True, help_text='Email address that receives important notifications.')
    auto_add_new_groups = models.ManyToManyField(
        'apostello.RecipientGroup',
        blank=True,
        help_text='Any brand new people will be added to the groups'
        ' selected here',
    )
    sms_expiration_date = models.DateField(
        "SMS Expiration Date",
        null=True,
        help_text='If this date is set, any messages older than this will be'
        ' removed from the database.'
    )
    sms_rolling_expiration_days = models.PositiveIntegerField(
        "Rolling SMS Expiration",
        null=True,
        blank=True,
        help_text='The number of days a message will be kept by apostello before'
        ' being deleted.'
        ' If blank, then messages will be kept forever.'
    )
    slack_url = models.URLField(
        blank=True, help_text='Post all incoming messages to this slack hook.'
        ' Leave blank to disable.'
    )
    sync_elvanto = models.BooleanField(
        default=False,
        help_text='Toggle automatic syncing of Elvanto groups.'
        ' Syncing will be done every 24 hours.',
    )
    not_approved_msg = models.TextField(
        default='\n\nYour account has not yet been approved.'
        '\n\nAll new accounts require approval to help prevent abuse.'
        ' Someone should approve your account soon.'
        '\n\nPlease get in touch if you believe you are seeing this in error.'
        '\n',
        help_text='This message will be shown on the "not approved" page.',
    )
    # email sending settings
    email_host = models.URLField(
        blank=True,
        help_text='Email host.'
        ' This will override values in settings.py',
    )
    email_port = models.PositiveIntegerField(
        blank=True,
        null=True,
        help_text='Email host port.'
        ' This will override values in settings.py',
    )
    email_username = models.CharField(
        blank=True,
        max_length=255,
        help_text='Email user name.'
        ' This will override values in settings.py',
    )
    email_password = models.CharField(
        blank=True,
        max_length=255,
        help_text='Email password.'
        ' This will override values in settings.py',
    )
    email_from = models.EmailField(
        blank=True,
        help_text='Email will be sent from this address.'
        ' This will override values in settings.py',
    )

    def __str__(self):
        """Pretty representation."""
        return u"Site Configuration"

    def save(self, *args, **kwargs):
        super(SiteConfiguration, self).save(*args, **kwargs)
        for u in User.objects.all():
            key = make_template_fragment_key('elmSettings', [u])
            cache.delete(key)

    class Meta:
        verbose_name = "Site Configuration"


class DefaultResponses(SingletonModel):
    """
    Stores the site wide default responses.

    This is a singleton object, there should only be a single instance
    of this model.
    """
    keyword_no_match = models.TextField(
        max_length=1000,
        blank=True,
        default='Thank you, %name%, your message has not matched any of our'
        ' keywords. Please correct your message and try again.',
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when an SMS does not match any keywords.'
        ' ("%name%" will be replaced with the user\'s first name)'
    )
    default_no_keyword_auto_reply = models.TextField(
        max_length=1000,
        default='Thank you, %name%, your message has been received.',
        validators=[less_than_sms_char_limit],
        help_text='This message will be sent when an SMS matches a keyword,'
        ' but that keyword has no reply set.'
    )
    default_no_keyword_not_live = models.TextField(
        max_length=1000,
        default='Thank you, %name%, for your text.'
        ' But "%keyword%" is not active...',
        validators=[less_than_sms_char_limit],
        help_text='Default message for when a keyword is not currently active.'
        ' ("%keyword" will be replaced with the matched keyword)'
    )
    start_reply = models.TextField(
        max_length=1000,
        default="Thanks for signing up!",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "start".'
    )
    auto_name_request = models.TextField(
        max_length=1000,
        default="Hi there, I'm afraid we currently don't have your number in"
        " our address book. Could you please reply in the format"
        "\n'name John Smith'",
        validators=[less_than_sms_char_limit],
        help_text='Message to send when we first receive a message from'
        ' someone not in the contacts list.'
    )
    name_update_reply = models.TextField(
        max_length=1000,
        default="Thanks %s!",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "name".'
        ' ("%s" is replaced with the person\'s first name)'
    )
    name_failure_reply = models.TextField(
        max_length=1000,
        default="Something went wrong, sorry,"
        " please try again with the format 'name John Smith'.",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "name"'
        ' but we are unable to parse their name.'
    )

    def __str__(self):
        """Pretty representation."""
        return u"Default Responses"

    class Meta:
        verbose_name = "Default Responses"
