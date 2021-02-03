from aodhv2.common import send
from aodhv2.arg_converter import get_by_name_or_uuid_multiple


@send('post')
def alarm_create(**kwargs):
    url = '/alarms'
    return url, kwargs


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('get')
def alarm_get_details(alarm_id, **kwargs):
    url = '/alarms/{}'.format(alarm_id)
    return url, None


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('put')
def alarm_update(alarm_id, **kwargs):
    url = '/alarms/{}'.format(alarm_id)
    return url, kwargs


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('delete')
def alarm_delete(alarm_id, **kwargs):
    url = '/alarms/{}'.format(alarm_id)
    return url, None


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('get')
def alarm_history_get(alarm_id, **kwargs):
    url = '/alarms/{}/history'.format(alarm_id)
    return url, None


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('put')
def alarm_state_set(alarm_id, state, **kwargs):
    url = '/alarms/{}/state'.format(alarm_id)
    return url, {'state': state}


@get_by_name_or_uuid_multiple([('alarm', 'alarm_id')])
@send('get')
def alarm_state_get(alarm_id, **kwargs):
    url = '/alarms/{}/state'.format(alarm_id)
    return url, None
