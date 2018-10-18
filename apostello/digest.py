from collections import namedtuple

from django.contrib.sites.models import Site
from django.template.loader import render_to_string


class Table:
    def __init__(self, col_names, col_ids, responses):
        self.col_names = col_names
        self.col_ids = col_ids
        self.responses = responses
        self.col_widths = self.calculate_widths()

    def calculate_widths(self):
        return [self._column_width(i, n) for i, n in zip(self.col_ids, self.col_names)]

    def _column_width(self, id, name):
        sizes = [len(str(getattr(x, id))) for x in self.responses]
        sizes.append(len(name))
        return max(sizes)

    def _justify(self, cells):
        return [n.ljust(w) for n, w in zip(cells, self.col_widths)]

    def _add_pipes(self, cells):
        return "| {0} |".format(" | ".join(cells))

    def header_str(self):
        justified = self._justify(self.col_names)
        return self._add_pipes(justified)

    def row_str(self, resp):
        cells = [str(getattr(resp, i)) for i in self.col_ids]
        justified = self._justify(cells)
        return self._add_pipes(justified)

    def __str__(self):
        header = self.header_str()
        header_underline = "|{0}|".format("-" * (len(header) - 2))
        rows = [self.row_str(r) for r in self.responses]
        return "\n".join([header, header_underline] + rows)


def create_email_body(keyword, new_responses):
    """Create email body for nightly digest"""
    col_names = ["From", "Message", "Time Received"]
    col_ids = ["sender_name", "content", "time_received"]
    context = {
        "keyword": keyword,
        "table": Table(col_names, col_ids, new_responses),
        "domain": Site.objects.all()[0].domain,
    }
    return render_to_string("apostello/email_digest.txt", context)
