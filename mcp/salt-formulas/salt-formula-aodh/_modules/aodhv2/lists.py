from aodhv2.common import send

try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode


@send('get')
def alarm_list(**kwargs):
    url = '/alarms'
    return url, None