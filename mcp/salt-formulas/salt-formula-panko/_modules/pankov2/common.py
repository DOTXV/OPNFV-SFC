import logging

try:
    import os_client_config
except ImportError:
    os_client_config = None
from salt import exceptions

log = logging.getLogger(__name__)


class PankoException(Exception):

    _msg = "Panko module exception occured."

    def __init__(self, message=None, **kwargs):
        super(PankoException, self).__init__(message or self._msg)


class NoPankoEndpoint(PankoException):
    _msg = "Panko endpoint not found in keystone catalog."


class NoAuthPluginConfigured(PankoException):
    _msg = ("You are using keystoneauth auth plugin that does not support "
            "fetching endpoint list from token (noauth or admin_token).")


class NoCredentials(PankoException):
    _msg = "Please provide cloud name present in clouds.yaml."


class ResourceNotFound(PankoException):
    _msg = "Uniq resource: {resource} with name: {name} not found."

    def __init__(self, resource, name, **kwargs):
        super(PankoException, self).__init__(
            self._msg.format(resource=resource, name=name))


class MultipleResourcesFound(PankoException):
    _msg = "Multiple resource: {resource} with name: {name} found."

    def __init__(self, resource, name, **kwargs):
        super(PankoException, self).__init__(
            self._msg.format(resource=resource, name=name))


def _get_raw_client(cloud_name):
    if not os_client_config:
        raise exceptions.SaltInvocationError(
            "Cannot load os-client-config. Please check your environment "
            "configuration.")
    service_type = 'event'
    config = os_client_config.OpenStackConfig()
    cloud = config.get_one_cloud(cloud_name)
    api_version = 'v2'
    try:
        # NOTE(pas-ha) for Queens and later,
        # 'version' kwarg in absent for Pike and older
        adapter = cloud.get_session_client(service_type, version=api_version)
    except TypeError:
        adapter = cloud.get_session_client(service_type)
        adapter.version = api_version
    try:
        access_info = adapter.session.auth.get_access(adapter.session)
        endpoints = access_info.service_catalog.get_endpoints()
    except (AttributeError, ValueError):
        e = NoAuthPluginConfigured()
        log.exception('%s' % e)
        raise e
    if service_type not in endpoints:
        if not service_type:
            e = NoPankoEndpoint()
            log.error('%s' % e)
            raise e
    return adapter


def send(method, microversion_header=None):
    def wrap(func):
        def wrapped_f(*args, **kwargs):
            headers = kwargs.pop('headers', {})
            if kwargs.get('microversion'):
                headers.setdefault(microversion_header,
                                   kwargs.get('microversion'))
            cloud_name = kwargs.pop('cloud_name')
            if not cloud_name:
                e = NoCredentials()
                log.error('%s' % e)
                raise e
            adapter = _get_raw_client(cloud_name)
            # Remove salt internal kwargs
            kwarg_keys = list(kwargs.keys())
            for k in kwarg_keys:
                if k.startswith('__'):
                    kwargs.pop(k)
            url, json = func(*args, **kwargs)
            if json:
                response = getattr(adapter, method)(url, headers=headers,
                                                    json=json)
            else:
                response = getattr(adapter, method)(url, headers=headers)
            if not response.content:
                return {}
            try:
                resp = response.json()
            except:
                resp = response.content
            return resp
        return wrapped_f
    return wrap
