import csv

from django.contrib.auth.decorators import login_required
from django.urls import reverse
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect
from django.template.response import TemplateResponse

from apostello.decorators import keyword_access_check
from apostello.models import Keyword


@keyword_access_check
@login_required
def keyword_csv(request, keyword):
    """Return a CSV with the responses for a single keyword."""
    keyword = get_object_or_404(Keyword, keyword=keyword)
    # Create the HttpResponse object with the appropriate CSV header.
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="{0}.csv"'.format(keyword.keyword)
    writer = csv.writer(response)
    writer.writerow(['From', 'Time', 'Keyword', 'Message'])
    # write response rows
    for sms_ in keyword.fetch_matches():
        writer.writerow([sms_.sender_name, sms_.time_received, sms_.matched_keyword, sms_.content])

    return response
