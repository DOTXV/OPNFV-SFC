import logging


def __virtual__():
    return 'aodhv2' if 'aodhv2.alarm_list' in __salt__ else False  # noqa


log = logging.getLogger(__name__)


def _aodhv2_call(fname, *args, **kwargs):
    return __salt__['aodhv2.{}'.format(fname)](*args, **kwargs)  # noqa


def _resource_present(resource, name, cloud_name, **kwargs):
    try:
        method_name = '{}_get_details'.format(resource)
        exact_resource = _aodhv2_call(
            method_name, name, cloud_name=cloud_name
        )[resource]
    except Exception as e:
        if 'ResourceNotFound' in repr(e):
            try:
                method_name = '{}_create'.format(resource)
                resp = _aodhv2_call(
                    method_name, name=name, cloud_name=cloud_name, **kwargs
                )
            except Exception as e:
                log.exception('Aodh {0} create failed with {1}'.
                    format(resource, e))
                return _failed('create', name, resource)
            return _succeeded('create', name, resource, resp)
        elif 'MultipleResourcesFound' in repr(e):
            return _failed('find', name, resource)
        else:
            raise

    to_update = {}
    for key in kwargs:
        if key not in exact_resource or kwargs[key] != exact_resource[key]:
            to_update[key] = kwargs[key]
    try:
        method_name = '{}_update'.format(resource)
        resp = _aodhv2_call(
            method_name, name, cloud_name=cloud_name, **to_update
        )
    except Exception as e:
        log.exception('Aodh {0} update failed with {1}'.format(resource, e))
        return _failed('update', name, resource)
    return _succeeded('update', name, resource, resp)


def _resource_absent(resource, name, cloud_name):
    try:
        method_name = '{}_get_details'.format(resource)
        _aodhv2_call(
            method_name, name, cloud_name=cloud_name
        )[resource]
    except Exception as e:
        if 'ResourceNotFound' in repr(e):
            return _succeeded('absent', name, resource)
        if 'MultipleResourcesFound' in repr(e):
            return _failed('find', name, resource)
    try:
        method_name = '{}_delete'.format(resource)
        _aodhv2_call(
            method_name, name, cloud_name=cloud_name
        )
    except Exception as e:
        log.error('Aodh delete {0} failed with {1}'.format(resource, e))
        return _failed('delete', name, resource)
    return _succeeded('delete', name, resource)


def alarm_present(name, cloud_name, **kwargs):
    return _resource_present('alarm', name, cloud_name, **kwargs)


def alarm_absent(name, cloud_name):
    return _resource_absent('alarm', name, cloud_name)


def _succeeded(op, name, resource, changes=None):
    msg_map = {
        'create': '{0} {1} created',
        'delete': '{0} {1} removed',
        'update': '{0} {1} updated',
        'no_changes': '{0} {1} is in desired state',
        'absent': '{0} {1} not present',
        'resources_moved': '{1} resources were moved from {0}',
    }
    changes_dict = {
        'name': name,
        'result': True,
        'comment': msg_map[op].format(resource, name),
        'changes': changes or {},
    }
    return changes_dict


def _failed(op, name, resource):
    msg_map = {
        'create': '{0} {1} failed to create',
        'delete': '{0} {1} failed to delete',
        'update': '{0} {1} failed to update',
        'find': '{0} {1} found multiple {0}',
        'resources_moved': 'failed to move {1} from {0}',
    }
    changes_dict = {
        'name': name,
        'result': False,
        'comment': msg_map[op].format(resource, name),
        'changes': {},
    }
    return changes_dict
