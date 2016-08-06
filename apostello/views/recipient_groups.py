from django.views.generic.edit import FormView

from apostello.forms import GroupAllCreateForm
from apostello.mixins import ProfilePermsMixin
from apostello.models import Recipient, RecipientGroup


class CreateAllGroupView(ProfilePermsMixin, FormView):
    """View to handle creation of an 'all' group."""
    template_name = 'apostello/item.html'
    form_class = GroupAllCreateForm
    model = RecipientGroup
    required_perms = []
    success_url = '/group/all/'

    def get_context_data(self, **kwargs):
        """Inject intro and button text into context."""
        context = super(CreateAllGroupView, self).get_context_data(**kwargs)
        context['submit_text'] = 'Create'
        context['intro_text'] = 'You can use this form to create a new group' \
            ' that contains all currently active contacts.'
        return context

    def form_valid(self, form):
        """Create the group and add all active users."""
        g, created = RecipientGroup.objects.get_or_create(
            name=form.cleaned_data['group_name'],
            defaults={'description': 'Created using "All" form'},
        )
        if not created:
            g.recipient_set.clear()
        for r in Recipient.objects.filter(is_archived=False):
            g.recipient_set.add(r)
        g.save()
        return super(CreateAllGroupView, self).form_valid(form)
