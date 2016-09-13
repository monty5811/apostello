from django.contrib import messages
from django.shortcuts import get_object_or_404, redirect
from django.template.response import TemplateResponse
from django.views.generic import View

from apostello.exceptions import ArchivedItemException
from apostello.mixins import ProfilePermsMixin
from apostello.models import Keyword
from apostello.utils import exists_and_archived


class SimpleView(ProfilePermsMixin, View):
    """Simple view that can ensure user is logged in and has permissions."""
    template_name = ''
    required_perms = []
    rest_uri = None

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        user_profile = self.request.user.profile
        context = {'show_tour': user_profile.show_tour}
        if user_profile.show_tour:
            # first run, disable tour on subsequent loads
            user_profile.show_tour = False
            user_profile.save()

        if self.rest_uri is not None:
            context['rest_uri'] = self.rest_uri

        return TemplateResponse(request, self.template_name, context)


class ItemView(ProfilePermsMixin, View):
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
        context = {}
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

        return TemplateResponse(request, "apostello/item.html", context)

    def post(self, request, *args, **kwargs):
        """
        Handle form post.

        If an object is created that matches an existing, archived, object, the
        user will be redirected to the existing object and told how to restore
        the archived object.
        """
        try:
            instance = self.model_class.objects.get(pk=kwargs['pk']
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
                    request, "'{0}' already exists."
                    " You can open the menu to restore it.".
                    format(str(new_instance))
                )
                return redirect(new_instance.get_absolute_url)
            except ArchivedItemException:
                return TemplateResponse(
                    request, "apostello/item.html", {
                        'form': form,
                        'redirect_url': self.redirect_url,
                        'submit_text': "Submit",
                        'identifier': self.identifier,
                        'object': None
                    }
                )
