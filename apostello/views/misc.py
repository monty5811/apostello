from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist
from django.core.urlresolvers import reverse
from django.shortcuts import redirect
from django.template.response import TemplateResponse
from django.views.generic import TemplateView, View
from django.views.generic.edit import UpdateView
from rest_framework.authtoken.models import Token

from apostello.forms import UserProfileForm
from apostello.mixins import ProfilePermsMixin
from apostello.models import UserProfile
from site_config.models import SiteConfiguration


class NotApprovedView(TemplateView):
    """Simple view that presents the not approved page."""
    template_name = 'apostello/not_approved.html'

    def get_context_data(self, **kwargs):
        """Inject not approved message into context."""
        context = super(NotApprovedView, self).get_context_data(**kwargs)
        s = SiteConfiguration.get_solo()
        context['msg'] = s.not_approved_msg
        return context


class UserProfileView(ProfilePermsMixin, UpdateView):
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


class APISetupView(ProfilePermsMixin, View):
    """Simple view that can ensure user is logged in and has permissions."""
    template_name = 'apostello/api-setup.html'
    required_perms = []

    def get(self, request, *args, **kwargs):
        """Handle get requests."""
        context = {}
        try:
            context['api_token'] = request.user.auth_token
        except ObjectDoesNotExist:
            context['api_token'] = 'No API Token Generated'

        return TemplateResponse(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        """Handle token generation."""
        if request.GET.get('regen') is not None:
            t, created = Token.objects.get_or_create(user=request.user)
            if not created:
                t.delete()
                Token.objects.create(user=request.user)

        if request.GET.get('delete') is not None:
            try:
                t = Token.objects.get(user=request.user)
                t.delete()
            except Token.DoesNotExist:
                # no token to delete, just continue
                pass

        return redirect(reverse('api-setup'))
