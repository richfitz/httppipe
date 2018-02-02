import requests
import sys

IS_WINDOWS_PLATFORM = (sys.platform == 'win32')

if IS_WINDOWS_PLATFORM:
    from npipeconn import NpipeAdapter as HttpAdapter
    from npipesocket import NpipeSocket
else:
    from unixconn import UnixAdapter as HttpAdapter

# Start with the unix socket version because that's fairly easy to get
# going with and I can test it locally.  Then we can copy over all the
# bits for the windows support and test that locally there.
class Transporter(requests.Session):
    def __init__(self, base_url):
        super(Transporter, self).__init__()
        self.base_url = base_url
        self._custom_adapter = HttpAdapter(base_url)
        self.mount('http://', self._custom_adapter)
        self._unmount('https://')
        self.base_url = 'http://localhost'

    def _unmount(self, *args):
        for proto in args:
            self.adapters.pop(proto)

    def simple_request(self, verb, url, headers, data = None):
        res = self.request(method = verb, url = url, headers = headers,
                           data = data)
        headers = '\n'.join(
            ['{}: {}'.format(*i) for i in res.raw.headers.items()])
        content = res.content
        is_binary = content.find('\x00') > 0
        if is_binary:
            content = [ord(i) for i in content]
        return {'url': res.url,
                'status_code': res.status_code,
                'headers': headers,
                'is_binary': is_binary,
                'content': content}
