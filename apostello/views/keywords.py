import csv

from django.contrib.auth.decorators import login_required
from django.core.urlresolvers import reverse
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect
from django.template.response import TemplateResponse

from apostello.decorators import keyword_access_check
from apostello.forms import ArchiveKeywordResponses
from apostello.models import Keyword


@keyword_access_check
@login_required
def keyword_responses(request, pk, archive=False):
    """Display the responses for a single keyword."""
    keyword = get_object_or_404(Keyword, pk=pk)
    context = {"keyword": keyword, "archive": archive}

    if archive is False:
        context['form'] = ArchiveKeywordResponses
        if request.method == 'POST':
            form = ArchiveKeywordResponses(request.POST)
            context['form'] = form
            if form.is_valid(
            ) and form.cleaned_data['tick_to_archive_all_responses']:
                for sms in keyword.fetch_matches():
                    sms.archive()
                return redirect(
                    reverse(
                        "keyword_responses", kwargs={'pk': pk}
                    )
                )

    return TemplateResponse(
        request, "apostello/keyword_responses.html", context
    )


@keyword_access_check
@login_required
def keyword_csv(request, pk):
    """Return a CSV with the responses for a single keyword."""
    keyword = get_object_or_404(Keyword, pk=pk)
    # Create the HttpResponse object with the appropriate CSV header.
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="{0}.csv"'.format(
        keyword.keyword
    )
    writer = csv.writer(response)
    writer.writerow(['From', 'Time', 'Keyword', 'Message'])
    # write response rows
    for sms_ in keyword.fetch_matches():
        writer.writerow(
            [
                sms_.sender_name, sms_.time_received, sms_.matched_keyword,
                sms_.content
            ]
        )

    return response
