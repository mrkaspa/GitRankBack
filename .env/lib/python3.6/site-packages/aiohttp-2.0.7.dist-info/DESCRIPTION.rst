Async http client/server framework
==================================

.. image:: https://raw.githubusercontent.com/aio-libs/aiohttp/master/docs/_static/aiohttp-icon-128x128.png
  :height: 64px
  :width: 64px
  :alt: aiohttp logo

.. image:: https://travis-ci.org/aio-libs/aiohttp.svg?branch=master
  :target:  https://travis-ci.org/aio-libs/aiohttp
  :align: right

.. image:: https://codecov.io/gh/aio-libs/aiohttp/branch/master/graph/badge.svg
  :target: https://codecov.io/gh/aio-libs/aiohttp

.. image:: https://badge.fury.io/py/aiohttp.svg
    :target: https://badge.fury.io/py/aiohttp


aiohttp 2.0 release!
--------------------

For this release we completely refactored low-level implementation of http handling.
Finally `uvloop` gives performance improvement. Overall performance improvement
should be around 70-90% compared to 1.x version.

We took opportunity to refactor long standing api design problems across whole package.
Client exceptions handling has been cleaned up and now much more straight forward. Client payload
management simplified and allows to extend with any custom type. Client connection pool
implementation has been redesigned as well, now there is no need for actively releasing response objects,
aiohttp handles connection release automatically.

Another major change, we moved aiohttp development to public organization https://github.com/aio-libs

With this amount of api changes we had to make backward incompatible changes. Please check this migration document http://aiohttp.readthedocs.io/en/latest/migration.html

Please report problems or annoyance with with api to https://github.com/aio-libs/aiohttp


Features
--------

- Supports both client and server side of HTTP protocol.
- Supports both client and server Web-Sockets out-of-the-box.
- Web-server has middlewares and pluggable routing.


Getting started
---------------

Client
^^^^^^

To retrieve something from the web:

.. code-block:: python

  import aiohttp
  import asyncio

  async def fetch(session, url):
      with aiohttp.Timeout(10, loop=session.loop):
          async with session.get(url) as response:
              return await response.text()

  async def main(loop):
      async with aiohttp.ClientSession(loop=loop) as session:
          html = await fetch(session, 'http://python.org')
          print(html)

  if __name__ == '__main__':
      loop = asyncio.get_event_loop()
      loop.run_until_complete(main(loop))


Server
^^^^^^

This is simple usage example:

.. code-block:: python

    from aiohttp import web

    async def handle(request):
        name = request.match_info.get('name', "Anonymous")
        text = "Hello, " + name
        return web.Response(text=text)

    async def wshandler(request):
        ws = web.WebSocketResponse()
        await ws.prepare(request)

        async for msg in ws:
            if msg.type == web.MsgType.text:
                await ws.send_str("Hello, {}".format(msg.data))
            elif msg.type == web.MsgType.binary:
                await ws.send_bytes(msg.data)
            elif msg.type == web.MsgType.close:
                break

        return ws


    app = web.Application()
    app.router.add_get('/echo', wshandler)
    app.router.add_get('/', handle)
    app.router.add_get('/{name}', handle)

    web.run_app(app)


Note: examples are written for Python 3.5+ and utilize PEP-492 aka
async/await.  If you are using Python 3.4 please replace ``await`` with
``yield from`` and ``async def`` with ``@coroutine`` e.g.::

    async def coro(...):
        ret = await f()

should be replaced by::

    @asyncio.coroutine
    def coro(...):
        ret = yield from f()

Documentation
-------------

https://aiohttp.readthedocs.io/

Discussion list
---------------

*aio-libs* google group: https://groups.google.com/forum/#!forum/aio-libs

Requirements
------------

- Python >= 3.4.2
- async-timeout_
- chardet_
- multidict_
- yarl_

Optionally you may install the cChardet_ and aiodns_ libraries (highly
recommended for sake of speed).

.. _chardet: https://pypi.python.org/pypi/chardet
.. _aiodns: https://pypi.python.org/pypi/aiodns
.. _multidict: https://pypi.python.org/pypi/multidict
.. _yarl: https://pypi.python.org/pypi/yarl
.. _async-timeout: https://pypi.python.org/pypi/async_timeout
.. _cChardet: https://pypi.python.org/pypi/cchardet

License
-------

``aiohttp`` is offered under the Apache 2 license.


Keepsafe
--------

The aiohttp community would like to thank Keepsafe (https://www.getkeepsafe.com) for it's support in the early days of the project.


Source code
------------

The latest developer version is available in a github repository:
https://github.com/aio-libs/aiohttp

Benchmarks
----------

If you are interested in by efficiency, AsyncIO community maintains a
list of benchmarks on the official wiki:
https://github.com/python/asyncio/wiki/Benchmarks

Changes
=======

2.0.7 (2017-04-12)
------------------

- Fix *pypi* distribution

- Fix exception description #1807

- Handle socket error in FileResponse #1773

- Cancel websocket heartbeat on close #1793


2.0.6 (2017-04-06)
------------------

- Fix ``web.run_app`` not to bind to default host-port pair if only socket is
  passed #1786

- Keeping blank values for `request.post()` and `multipart.form()` #1765

- TypeError in ResponseHandler.data_received #1770


2.0.5 (2017-03-29)
------------------

- Memory leak with aiohttp.request #1756

- Disable cleanup closed ssl transports by default.

- Exception in request handling if the server responds before the body is sent #1761


2.0.4 (2017-03-27)
------------------

- Memory leak with aiohttp.request #1756

- Encoding is always UTF-8 in POST data #1750

- Do not add "Content-Disposition" header by default #1755


2.0.3 (2017-03-24)
------------------

- Call https website through proxy will cause error #1745

- Fix exception on multipart/form-data post if content-type is not set #1743


2.0.2 (2017-03-21)
------------------

- Fixed Application.on_loop_available signal #1739

- Remove debug code


2.0.1 (2017-03-21)
------------------

- Fix allow-head to include name on route #1737

- Fixed AttributeError in WebSocketResponse.can_prepare #1736


2.0.0 (2017-03-20)
------------------

- Added `json` to `ClientSession.request()` method #1726

- Added session's `raise_for_status` parameter, automatically calls raise_for_status() on any request. #1724

- `response.json()` raises `ClientReponseError` exception if response's
  content type does not match #1723

- Cleanup timer and loop handle on any client exception.

- Deprecate `loop` parameter for Application's constructor


`2.0.0rc1` (2017-03-15)
-----------------------

- Properly handle payload errors #1710

- Added `ClientWebSocketResponse.get_extra_info()` #1717

- It is not possible to combine Transfer-Encoding and chunked parameter,
  same for compress and Content-Encoding #1655

- Connector's `limit` parameter indicates total concurrent connections.
  New `limit_per_host` added, indicates total connections per endpoint. #1601

- Use url's `raw_host` for name resolution #1685

- Change `ClientResponse.url` to `yarl.URL` instance #1654

- Add max_size parameter to web.Request reading methods #1133

- Web Request.post() stores data in temp files #1469

- Add the `allow_head=True` keyword argument for `add_get` #1618

- `run_app` and the Command Line Interface now support serving over
  Unix domain sockets for faster inter-process communication.

- `run_app` now supports passing a preexisting socket object. This can be useful
  e.g. for socket-based activated applications, when binding of a socket is
  done by the parent process.

- Implementation for Trailer headers parser is broken #1619

- Fix FileResponse to not fall on bad request (range out of file size)

- Fix FileResponse to correct stream video to Chromes

- Deprecate public low-level api #1657

- Deprecate `encoding` parameter for ClientSession.request() method

- Dropped aiohttp.wsgi #1108

- Dropped `version` from ClientSession.request() method

- Dropped websocket version 76 support #1160

- Dropped: `aiohttp.protocol.HttpPrefixParser`  #1590

- Dropped: Servers response's `.started`, `.start()` and `.can_start()` method  #1591

- Dropped:  Adding `sub app` via `app.router.add_subapp()` is deprecated
  use `app.add_subapp()` instead #1592

- Dropped: `Application.finish()` and `Application.register_on_finish()`  #1602

- Dropped: `web.Request.GET` and `web.Request.POST`

- Dropped: aiohttp.get(), aiohttp.options(), aiohttp.head(),
  aiohttp.post(), aiohttp.put(), aiohttp.patch(), aiohttp.delete(), and
  aiohttp.ws_connect() #1593

- Dropped: `aiohttp.web.WebSocketResponse.receive_msg()` #1605

- Dropped: `ServerHttpProtocol.keep_alive_timeout` attribute and
  `keep-alive`, `keep_alive_on`, `timeout`, `log` constructor parameters #1606

- Dropped: `TCPConnector's`` `.resolve`, `.resolved_hosts`, `.clear_resolved_hosts()`
  attributes and `resolve` constructor  parameter #1607

- Dropped `ProxyConnector` #1609

