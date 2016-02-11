from django.db import models
from solo.models import SingletonModel

from apostello.validators import less_than_sms_char_limit


class SiteConfiguration(SingletonModel):
    """
    Stores site wide configuration options.

    This is a singleton object, there should only be a single instance
    of this model.
    """
    site_name = models.CharField(max_length=255, default='apostello')
    disable_email_login_form = models.BooleanField(
        default=False,
        help_text=
        'Tick this to hide the login with email form. Note, you will need to have setup login with Google, or users will have no way into the site.'
    )
    sms_char_limit = models.PositiveSmallIntegerField(
        default=160,
        help_text='SMS length limit.')
    disable_all_replies = models.BooleanField(
        default=False,
        help_text='Tick this box to disable all automated replies')
    office_email = models.EmailField(
        blank=True,
        help_text='Email to send information emails to')
    from_email = models.EmailField(blank=True,
                                   help_text='Email to send emails from')
    slack_url = models.URLField(
        blank=True,
        help_text='Post all incoming messages to this slack hook. '
        'Leave blank to disable.'
    )
    sync_elvanto = models.BooleanField(
        default=False,
        help_text='Toggle automatic syncing of Elvanto groups. '
        'Sync will be done overnight',
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
        help_text='This message will be sent when a SMS matched a keyword, '
        'but that keyword has no reply set'
    )
    default_no_keyword_not_live = models.TextField(
        max_length=1000,
        default='Thank you, %name%, for your text. '
        'But "%keyword%" is not active..',
        validators=[less_than_sms_char_limit],
        help_text='Default message for when a keyword is not currently active.'
    )
    keyword_no_match = models.TextField(
        max_length=1000,
        default='Thank you, %name%, your message has not matched any of our '
        'keywords. Please correct your message and try again.',
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
        default="Something went wrong, sorry, "
        "please try again with the format 'name John Smith'.",
        validators=[less_than_sms_char_limit],
        help_text='Reply to use when someone matches "name"'
        'with bad formatting.'
    )
    auto_name_request = models.TextField(
        max_length=1000,
        default="Hi there, I'm afraid we currently don't have your number in"
        "our address book. Could you please reply in the format"
        "\n'name John Smith'",
        validators=[less_than_sms_char_limit],
        help_text='Message to send when we first receive a message from '
        'someone not in the contacts list.'
    )

    def __str__(self):
        """Pretty representation."""
        return u"Default Responses"

    class Meta:
        verbose_name = "Default Responses"
