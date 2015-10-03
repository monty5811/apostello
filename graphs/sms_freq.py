from django.core.cache import cache
from django.utils import timezone

from apostello.models import SmsInbound, SmsOutbound


def sms_graph_data(direction='in'):
    if direction == 'in':
        model_class = SmsInbound
        cache_id = 'igd'
    elif direction == 'out':
        model_class = SmsOutbound
        cache_id = 'ogd'

    smsdata = cache.get(cache_id)
    if smsdata is None:
        td = timezone.now()
        sms_list = model_class.objects.all()
        smsdata = []
        for x in range(-30, 1):
            delta = timezone.timedelta(days=x)
            today = td + delta
            if cache_id == 'ogd':
                num_of_sms = sms_list.filter(time_sent__year=today.year, time_sent__month=today.month, time_sent__day=today.day).count()
            elif cache_id == 'igd':
                num_of_sms = sms_list.filter(time_received__year=today.year, time_received__month=today.month, time_received__day=today.day).count()
            smsdata.append(num_of_sms)
        cache.set(cache_id, smsdata, 5 * 60)

    return smsdata
