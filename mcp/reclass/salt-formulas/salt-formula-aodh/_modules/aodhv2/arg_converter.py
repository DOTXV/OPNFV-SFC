import uuid
from aodhv2 import common
from aodhv2 import queries


class CheckId(object):
    def check_id(self, val):
        try:
            return str(uuid.UUID(val)).replace('-', '') == val
        except (TypeError, ValueError, AttributeError):
            return False


resource_lists = {
    'alarm': queries.query_post,
}


def get_by_name_or_uuid_multiple(resource_arg_name_pairs):
    def wrap(func):
        def wrapped_f(*args, **kwargs):
            results = []
            args_start = 0
            for index, (resource, arg_name) in enumerate(
                    resource_arg_name_pairs):
                if arg_name in kwargs:
                    ref = kwargs.pop(arg_name, None)
                else:
                    ref = args[index]
                    args_start += 1
                cloud_name = kwargs['cloud_name']
                checker = CheckId()
                if checker.check_id(ref):
                    results.append(ref)
                else:
                    # Then we have name not uuid
                    resp = resource_lists[resource](
                        name=ref, cloud_name=cloud_name)
                    if len(resp) == 0:
                        raise common.ResourceNotFound(resource, ref)
                    elif len(resp) > 1:
                        raise common.MultipleResourcesFound(resource, ref)
                    results.append(resp[0]['alarm_id'])
                results.extend(args[args_start:])
            return func(*results, **kwargs)
        return wrapped_f
    return wrap
