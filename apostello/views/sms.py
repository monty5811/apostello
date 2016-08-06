from django.contrib import messages
from django.views.generic.edit import FormView
from django_twilio.decorators import twilio_view
from twilio import twiml

from apostello.forms import SendAdhocRecipientsForm, SendRecipientGroupForm
from apostello.mixins import ProfilePermsMixin
from apostello.models import RecipientGroup
from apostello.reply import InboundSms
from site_config.models import SiteConfiguration


class SendView(ProfilePermsMixin, FormView):
    """Display send SMS form."""
    required_perms = []
    success_url = '/'

    def get_form(self, **kwargs):
        """Add user to form so we can check cost limits."""
        form = super(SendView, self).get_form(**kwargs)
        prepopulated_recipient = self.request.GET.get('recipient', None)
        if prepopulated_recipient is not None:
            form.initial['recipients'] = [prepopulated_recipient]
        form.user = self.request.user
        return form

    def get_context_data(self, **kwargs):
        """Inject not approved message into context."""
        context = super(SendView, self).get_context_data(**kwargs)
        context['js_path'] = self.template_name.replace('.html', '')
        return context


class SendAdhoc(SendView):
    """Display form for sending messages to individuals or ad-hoc groups."""
    form_class = SendAdhocRecipientsForm
    template_name = 'apostello/send_adhoc.html'
    success_url = '/send/adhoc/'

    def form_valid(self, form):
        """Send message and notify the user on valid form submission."""
        for recipient in form.cleaned_data['recipients']:
            # send and save message
            recipient.send_message(
                content=form.cleaned_data['content'],
                eta=form.cleaned_data['scheduled_time'],
                sent_by=str(self.request.user)
            )

        if form.cleaned_data['scheduled_time'] is None:
            messages.info(
                self.request, "Sending \"{0}\"...\n"
                "Please check the logs for verification...".format(
                    form.cleaned_data['content']
                )
            )
        else:
            messages.info(
                self.request, "'{0}' has been successfully queued.".format(
                    form.cleaned_data['content']
                )
            )

        return super(SendAdhoc, self).form_valid(form)


class SendGroup(SendView):
    """Display form for sending messages to a group."""
    form_class = SendRecipientGroupForm
    template_name = 'apostello/send_group.html'
    success_url = '/send/group/'

    def get_context_data(self, **kwargs):
        """Add the per group costs to context."""
        context = super(SendGroup, self).get_context_data(**kwargs)
        context['group_nums'] = [
            (x.id, x.recipient_set.all().count())
            for x in RecipientGroup.objects.all()
        ]
        return context

    def form_valid(self, form):
        """Send message and notify the user on valid form submission."""
        form.cleaned_data['recipient_group'].send_message(
            content=form.cleaned_data['content'],
            eta=form.cleaned_data['scheduled_time'],
            sent_by=str(self.request.user)
        )
        if form.cleaned_data['scheduled_time'] is None:
            messages.info(
                self.request, "Sending '{0}' to '{1}'...\n"
                "Please check the logs for verification...".format(
                    form.cleaned_data['content'],
                    form.cleaned_data['recipient_group']
                )
            )
        else:
            messages.info(
                self.request, "'{0}' has been successfully queued.".format(
                    form.cleaned_data['content']
                )
            )
        return super(SendGroup, self).form_valid(form)


@twilio_view
def sms(request):
    """
    Handle all incoming messages from Twilio.

    This is the start of the message processing pipeline.
    """
    r = twiml.Response()
    msg = InboundSms(request.POST)
    msg.start_bg_tasks()

    config = SiteConfiguration.get_solo()
    if not config.disable_all_replies:
        r.message(msg.reply)

    return r
