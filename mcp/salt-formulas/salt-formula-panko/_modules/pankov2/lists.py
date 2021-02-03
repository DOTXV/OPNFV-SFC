from pankov2.common import send

try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode


@send('get')
def event_list(**kwargs):
    url = '/events?{}'.format(urlencode(kwargs))
    return url, None


@send('get')
def event_type_list(**kwargs):
    url = '/event_types?{}'.format(urlencode(kwargs))
    return url, None
