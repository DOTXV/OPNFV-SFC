try:
    import os_client_config  # noqa
    from keystoneauth1 import exceptions as ka_exceptions  # noqa
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False

from pankov2 import lists

event_list = lists.event_list
event_type_list = lists.event_type_list


__all__ = ('event_list', 'event_type_list',)


def __virtual__():
    """Only load pankov2 if requirements are available."""
    if REQUIREMENTS_MET:
        return 'pankov2'
    else:
        return False, ("The pankov2 execution module cannot be loaded: "
                       "os_client_config or keystoneauth are unavailable.")