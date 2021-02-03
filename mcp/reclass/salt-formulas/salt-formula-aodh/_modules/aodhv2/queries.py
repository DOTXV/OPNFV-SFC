from aodhv2.common import send


# NOTE(opetrenko): currently we support only by name filtration
@send('post')
def query_post(name, **kwargs):
    url = '/query/alarms'
    json = {
        'filter': "{\"=\":{\"name\": \"%s\"}}" % name
    }
    return url, json
