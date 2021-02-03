try:
    import os_client_config  # noqa
    from keystoneauth1 import exceptions as ka_exceptions  # noqa
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False

from aodhv2 import lists
from aodhv2 import alarms

alarm_list = lists.alarm_list
alarm_create = alarms.alarm_create
alarm_get_details = alarms.alarm_get_details
alarm_update = alarms.alarm_update
alarm_delete = alarms.alarm_delete
alarm_history_get = alarms.alarm_history_get
alarm_state_set = alarms.alarm_state_set
alarm_state_get = alarms.alarm_state_get


__all__ = ('alarm_list', 'alarm_create', 'alarm_delete', 'alarm_get_details',
           'alarm_history_get', 'alarm_state_get', 'alarm_state_set',
           'alarm_update')


def __virtual__():
    """Only load aodhv2 if requirements are available."""
    if REQUIREMENTS_MET:
        return 'aodhv2'
    else:
        return False, ("The aodhv2 execution module cannot be loaded: "
                       "os_client_config or keystoneauth are unavailable.")
