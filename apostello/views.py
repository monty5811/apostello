import csv
import io

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.urlresolvers import reverse
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from django.views.generic import View
from django.views.generic.edit import UpdateView
from django_twilio.decorators import twilio_view
from phonenumber_field.validators import validate_international_phonenumber
from twilio import twiml

from apostello.decorators import check_user_perms, keyword_access_check
from apostello.exceptions import ArchivedItemException
from apostello.forms import (
    ArchiveKeywordResponses, CsvImport, SendAdhocRecipientsForm,
    SendRecipientGroupForm, UserProfileForm
)
from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword, Recipient, RecipientGroup, UserProfile
from apostello.reply import get_person_or_ask_for_name, reply_to_incoming
from apostello.tasks import log_msg_in, sms_to_slack
from apostello.utils import exists_and_archived
from site_config.models import SiteConfiguration


class SimpleView(LoginRequiredMixin, ProfilePermsMixin, View):
    """Simple view that can ensure user is logged in and has permissions."""
    template_name = ''
    required_perms = []

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        user_profile = self.request.user.profile
        context = {'show_tour': user_profile.show_tour}
        if user_profile.show_tour:
            # first run, disable tour on subsequent loads
            user_profile.show_tour = False
            user_profile.save()

        return render(request, self.template_name, context)


class SendAdhoc(LoginRequiredMixin, ProfilePermsMixin, View):
    """Display form for sending messages to individuals or ad-hoc groups."""
    required_perms = []
    context = {}

    def get(self, request, *args, **kwargs):
        """Display sending form."""
        context = self.context
        context['form'] = SendAdhocRecipientsForm
        return render(request, "apostello/send_adhoc.html", context)

    def post(self, request, *args, **kwargs):
        """Handle sending form submission."""
        context = self.context
        form = SendAdhocRecipientsForm(
            request.POST,
            ('recipients', ),
            user=request.user
        )
        if form.is_valid():
            for recipient in form.cleaned_data['recipients']:
                # send and save message
                recipient.send_message(
                    content=form.cleaned_data['content'],
                    eta=form.cleaned_data['scheduled_time'],
                    sent_by=str(request.user)
                )

            if form.cleaned_data['scheduled_time'] is None:
                messages.info(
                    request,
                    "Sending \"{0}\"...\nPlease check the logs for verification...".format(
                        form.cleaned_data['content']
                    )
                )
            else:
                messages.info(
                    request, "'{0}' has been successfully queued.".format(
                        form.cleaned_data['content']
                    )
                )
            return redirect(reverse("send_adhoc"))
        else:
            context['form'] = form
            return render(request, "apostello/send_adhoc.html", context)


class SendGroup(LoginRequiredMixin, ProfilePermsMixin, View):
    """Display form for sending messages to a group."""
    required_perms = []
    context = {}

    def get(self, request, *args, **kwargs):
        """Display sending form."""
        context = self.context
        context['form'] = SendRecipientGroupForm
        context['group_nums'] = [
            (x.id, x.recipient_set.all().count())
            for x in RecipientGroup.objects.all()
        ]
        return render(request, "apostello/send_group.html", context)

    def post(self, request, *args, **kwargs):
        """Handle sending form submission."""
        context = {}
        context['group_nums'] = [
            (x.id, x.calculate_cost) for x in RecipientGroup.objects.all()
        ]
        form = SendRecipientGroupForm(request.POST, user=request.user)
        if form.is_valid():
            form.cleaned_data['recipient_group'].send_message(
                content=form.cleaned_data['content'],
                eta=form.cleaned_data['scheduled_time'],
                sent_by=str(request.user)
            )
            if form.cleaned_data['scheduled_time'] is None:
                messages.info(
                    request,
                    "Sending '{0}' to '{1}'...\nPlease check the logs for verification...".format(
                        form.cleaned_data['content'],
                        form.cleaned_data['recipient_group']
                    )
                )
            else:
                messages.info(
                    request, "'{0}' has been successfully queued.".format(
                        form.cleaned_data['content']
                    )
                )
            return redirect(reverse('send_group'))
        else:
            context['form'] = form
            return render(request, "apostello/send_group.html", context)


class ItemView(LoginRequiredMixin, ProfilePermsMixin, View):
    """
    Display item form.

    Used to display the edit and create forms for Groups, Recipients and
    Keywords.
    """
    form_class = None
    redirect_url = ''
    identifier = ''
    model_class = None
    required_perms = []

    def get(self, request, *args, **kwargs):
        """Display item forms."""
        context = dict()
        context['identifier'] = self.identifier
        try:
            # if editing, form needs to be populated
            pk = kwargs['pk']
            instance = get_object_or_404(self.model_class, pk=pk)
            context['object'] = instance
            form = self.form_class(instance=instance)
            context['submit_text'] = "Update"
            if self.identifier == "keyword":
                context['keyword'] = Keyword.objects.get(pk=pk)
            if self.identifier == 'recipient':
                context['sms_history'] = True
        except KeyError:
            # otherwise, use a blank form
            form = self.form_class
            context['submit_text'] = "Submit"

        context['form'] = form

        return render(request, "apostello/item.html", context)

    def post(self, request, *args, **kwargs):
        """
        Handle form post.

        If an object is created that matches an existing, archived, object, the
        user will be redirected to the existing object and told how to restore
        the archived object.
        """
        try:
            instance = self.model_class.objects.get(
                pk=kwargs['pk']
            )  # original instance
            form = self.form_class(request.POST, instance=instance)
        except KeyError:
            form = self.form_class(request.POST)

        if form.is_valid():
            # if form is valid, save, otherwise handle different type of errors
            form.save()
            return redirect(self.redirect_url)
        else:
            try:
                # if we have a clash with existing object and it is archived,
                # redirect there, otherwise return form with errors
                new_instance = exists_and_archived(
                    form, self.model_class, self.identifier
                )
                messages.info(
                    request,
                    "'{0}' already exists. You can open the menu to restore it.".format(
                        str(new_instance)
                    )
                )
                return redirect(new_instance.get_absolute_url)
            except ArchivedItemException:
                return render(
                    request,
                    "apostello/item.html",
                    dict(
                        form=form,
                        redirect_url=self.redirect_url,
                        submit_text="Submit",
                        identifier=self.identifier,
                        object=None
                    )
                )


@keyword_access_check
@login_required
def keyword_responses(request, pk, archive=False):
    """Display the responses for a single keyword."""
    keyword = get_object_or_404(Keyword, pk=pk)

    if archive is False and request.method == 'POST':
        form = ArchiveKeywordResponses(request.POST)
        if form.is_valid() and form.cleaned_data[
            'tick_to_archive_all_responses'
        ]:
            for sms in keyword.fetch_matches():
                sms.is_archived = True
                sms.save()
            return redirect(reverse("keyword_responses", kwargs={'pk': pk}))

    context = {"keyword": keyword, "archive": archive}
    if archive is False:
        context["form"] = ArchiveKeywordResponses

    return render(request, "apostello/keyword_responses.html", context)


@keyword_access_check
@login_required
def keyword_csv(request, pk):
    """Return a CSV with the responses for a single keyword."""
    keyword = get_object_or_404(Keyword, pk=pk)
    # Create the HttpResponse object with the appropriate CSV header.
    response = HttpResponse(content_type='text/csv')
    response[
        'Content-Disposition'
    ] = 'attachment; filename="' + keyword.keyword + '.csv"'

    writer = csv.writer(response)
    writer.writerow(['From', 'Time', 'Keyword', 'Message'])

    # write response rows
    for sms_ in keyword.fetch_matches():
        writer.writerow(
            [
                sms_.sender_name.encode(
                    'utf8'
                ), sms_.time_received, sms_.matched_keyword.encode(
                    'utf8'
                ), sms_.content.encode('utf8')
            ]
        )

    return response


@check_user_perms
@login_required
def import_recipients(request):
    """Display the CSV import form."""
    context = {}
    if request.method == 'POST':
        form = CsvImport(request.POST)
        if form.is_valid():
            csv_string = u"first_name,last_name,number\n" + form.cleaned_data[
                'csv_data'
            ]
            data = [x for x in csv.DictReader(io.StringIO(csv_string))]
            bad_rows = list()
            for row in data:
                try:
                    validate_international_phonenumber(row['number'])
                    obj = Recipient.objects.get_or_create(
                        number=row['number']
                    )[0]
                    obj.first_name = row['first_name'].strip()
                    obj.last_name = row['last_name'].strip()
                    obj.is_archived = False
                    obj.full_clean()
                    obj.save()
                except Exception:
                    # catch bad rows and display to the user
                    bad_rows.append(row)
            if bad_rows:
                messages.warning(
                    request, "Uh oh, something went wrong with these imports!"
                )
                context['form'] = CsvImport()
                context['bad_rows'] = bad_rows
                return render(request, "apostello/importer.html", context)
            else:
                messages.success(request, "Importing your data now...")
                return redirect('/')

        context['form'] = form
        return render(request, 'apostello/importer.html', context)

    else:
        context['form'] = CsvImport()
        return render(request, 'apostello/importer.html', context)


class UserProfileView(LoginRequiredMixin, ProfilePermsMixin, UpdateView):
    """View to handle user profile form."""
    template_name = 'apostello/user_profile.html'
    form_class = UserProfileForm
    model = UserProfile
    required_perms = []
    success_url = '/users/profiles/'

    def form_valid(self, form):
        """Handle successful form submission."""
        messages.success(self.request, 'User profile updated')
        return super(UserProfileView, self).form_valid(form)


@twilio_view
def sms(request):
    """
    Handle all incoming messages from Twilio.

    This is the start of the message processing pipeline.
    """
    r = twiml.Response()
    params = request.POST
    from_ = params['From']
    sms_body = params['Body'].strip()
    keyword_obj = Keyword.match(sms_body)
    # get person object and optionally ask for their name
    person_from = get_person_or_ask_for_name(from_, sms_body, keyword_obj)
    log_msg_in.delay(params, timezone.now(), person_from.pk)
    sms_to_slack.delay(sms_body, person_from, keyword_obj)

    reply = reply_to_incoming(person_from, from_, sms_body, keyword_obj)

    config = SiteConfiguration.get_solo()
    if not config.disable_all_replies:
        r.message(reply)

    return r
