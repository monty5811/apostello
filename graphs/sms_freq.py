from django.core.cache import cache
from django.utils import timezone

from apostello.models import SmsInbound, SmsOutbound


def sms_graph_data(direction="in"):
    """
    Calculate the SMS activity from the past 30 days.

    Returns a list of ints - one for each day. Value is the number of messages.
    """
    if direction == "in":
        model_class = SmsInbound
        cache_id = "igd"
    elif direction == "out":
        model_class = SmsOutbound
        cache_id = "ogd"

    smsdata = cache.get(cache_id)
    if smsdata is None:
        td = timezone.now()
        # grab all the message timestamps from last 31 days as a list
        if cache_id == "ogd":
            sms_list = list(
                model_class.objects.filter(time_sent__gt=td - timezone.timedelta(days=31)).values_list(
                    "time_sent", flat=True
                )
            )
        elif cache_id == "igd":
            sms_list = list(
                model_class.objects.filter(time_received__gt=td - timezone.timedelta(days=31)).values_list(
                    "time_received", flat=True
                )
            )
        # count sms per day
        smsdata = []
        for x in range(-30, 1):
            delta = timezone.timedelta(days=x)
            today = td + delta
            num_of_sms = len(
                [x for x in sms_list if x.year == today.year and x.month == today.month and x.day == today.day]
            )
            smsdata.append(num_of_sms)

        cache.set(cache_id, smsdata, 5 * 60)

    return smsdata
