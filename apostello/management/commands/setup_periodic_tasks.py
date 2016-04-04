import datetime

from django.core.management.base import BaseCommand
from django_q.models import Schedule


def add_day_if_req(dt):
    if dt > datetime.datetime.now():
        return dt

    dt + datetime.timedelta(days=1)
    return dt


class Command(BaseCommand):
    """
    Checks Twilio's incoming logs for our number and updates the
    database to match.
    """
    args = ''
    help = 'Import incoming messages from twilio'

    def handle(self, *args, **options):
        now = datetime.datetime.now()
        now = now.replace(minute=0, second=0)
        next_3am = add_day_if_req(now.replace(hour=3))
        next_230am = add_day_if_req(now.replace(hour=2, minute=30))
        next_2130 = add_day_if_req(now.replace(hour=21, minute=30))
        if Schedule.objects.filter(
            func='apostello.tasks.pull_elvanto_groups').count() < 1:
            Schedule.objects.create(
                func='apostello.tasks.pull_elvanto_groups',
                schedule_type=Schedule.DAILY,
                repeats=-1,
                next_run=next_3am,
            )

        if Schedule.objects.filter(
            func='apostello.tasks.fetch_elvanto_groups').count() < 1:
            Schedule.objects.create(
                func='apostello.tasks.fetch_elvanto_groups',
                schedule_type=Schedule.DAILY,
                repeats=-1,
                next_run=next_230am,
            )

        if Schedule.objects.filter(
            func='apostello.tasks.send_keyword_digest').count() < 1:
            Schedule.objects.create(
                func='apostello.tasks.send_keyword_digest',
                schedule_type=Schedule.DAILY,
                repeats=-1,
                next_run=next_2130,
            )
